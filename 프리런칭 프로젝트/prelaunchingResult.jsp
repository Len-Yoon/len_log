<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="../head.jsp" flush="false"/>

<script type="text/javascript">
    var dataTable;
    var object;

    function setData() {
        object = $("#sb_prelaunching").val();

        var prelaunchingType = "new";

        $.ajax({
            url: '/event/selectPrelaunchingInfo',
            type: 'GET',
            data: {
                object: object
            },
            dataType: 'json',
            async: false,
            success: function (preLaunchingInfo) {
                prelaunchingType = preLaunchingInfo.is_new == "Y" ? "new" : "old";
            }, error: function (jqXHR, textStatus, errorThrown) {
                swal("ajax error", "prelaunchingResult.jsp - selectPrelaunchingInfo()", "error");
                console.log(jqXHR.responseText);
                console.log(textStatus);
                console.log(errorThrown);
            }
        });

        if (dataTable != null) dataTable.clear().destroy();

        dataTable = $("#result").DataTable({
            // DataTables - Features
            autoWidth: false,
            processing: true,
            // DataTables - Options
            dom: 'lBfrtip',
            lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]],
            order: [[0, "desc"]],
            // DataTables - Internationalisation
            language: {
                processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw" style="color: #000;"></i><span style="font-size: 2em;">Loading...</span>'
            },
            // Buttons
            buttons: ['copyHtml5', 'excelHtml5', 'csvHtml5'],
            // DataTables - Data
            ajax: {
                url: '/event/selectPrelaunchingUserInfo_DT',
                type: 'GET',
                data: {
                    object: object
                },
                dataType: 'json',
            },
            // DataTables - Columns
            columns: [
                {
                    className: 'center',
                    data: 'seq',
                    render: function(data, type, row, meta) {
                        var rtn = '<a href="javascript:;"';
                        rtn += 'onclick="selectPrelaunchingUserInfo(\'' + data + '\');" style="font-weight: bold; font-size: 13px;">';
                        rtn += meta.row + 1;
                        rtn += '</a>'

                        return rtn;
                    },
                    title: '번호',
                    width: '5%'
                },
                {
                    className: 'center',
                    data: 'object',
                    title: '구분',
                },
                {
                    className: 'center',
                    data: 'email',
                    title: '이메일',
                },
                {
                    className: 'center',
                    data: 'phone',
                    title: '연락처',
                },
                {
                    className: 'center',
                    title: '옵션1',
                    render: function(data, type, row, meta) {
                        var rtn = '';
                        if(prelaunchingType == 'new') {
                            rtn = row.option1;
                        } else {
                            rtn = row.keyboardFrame;
                        }

                        return rtn;
                    }
                },
                {
                    className: 'center',
                    title: '옵션2',
                    render: function(data, type, row, meta) {
                        var rtn = '';
                        if(prelaunchingType == 'new') {
                            rtn = row.option2;
                        } else {
                            rtn = row.keyboardSwitch;
                        }

                        return rtn;
                    }
                },
                {
                    className: 'center',
                    data: 'prelaunchingFlag',
                    title: '자동참여 여부'
                },
                {
                    className: 'center',
                    data: 'prelaunchingDate',
                    title: '프리런칭일자',
                },
                {
                    className: 'center',
                    data: 'exportSeq',
                    render: function(data, type, row, meta) {
                        var rtn = '';
                        if (data != 0) {
                            rtn += '이벤트대상 - ' + data;
                        }

                        return rtn;
                    },
                    title: '이벤트 참여여부',
                }
            ],
            // DataTables - Callbacks
            headerCallback: function (thead, data, start, end, display) {
                $(thead).find('th').each(function (index) {
                    // if (prelaunchingType == "new") {
                    //     $('th', thead).eq(4).addClass('hide');
                    //     $('th', thead).eq(5).addClass('hide');
                    //     $('th', thead).eq(6).removeClass('hide');
                    // }
                    // else {
                    //     $('th', thead).eq(4).removeClass('hide');
                    //     $('th', thead).eq(5).removeClass('hide');
                    //     $('th', thead).eq(6).addClass('hide');
                    // }

                    $('th', thead).eq(4).removeClass('hide');
                    $('th', thead).eq(5).removeClass('hide');
                    // $('th', thead).eq(6).addClass('hide');
                })
            },

            initComplete: function (row, data) {

                // Morris Chart 렌더링할 부모 <div> 및 각 데이터들 저장할 변수 초기화
                const chartsBox = document.querySelector('#prelaunching-charts');
                chartsBox.innerHTML = "";
                let autoPrelaunchingResult = null;
                let frameResult = null;
                let switchResult = null;

                var donutChartList = [
                    {
                        url: '/event/selectAutoPrelaunchingCount',
                        data: autoPrelaunchingResult,
                        element: 'autoPrelaunching-chart',
                    },
                    {
                        url: '/event/selectPrelaunchingFrameCountList',
                        data: frameResult,
                        element: 'frame-chart',
                    },
                    {
                        url: '/event/selectPrelaunchingSwitchCountList',
                        data: switchResult,
                        element: 'switch-chart',
                    },
                ];

                donutChartList.forEach((donutChartInfo) => {
                    $.ajax({
                        url: donutChartInfo.url,
                        type: 'GET',
                        data: {
                            object: object
                        },
                        dataType: 'json',
                        async: false,
                        success: function (result) {
                            if (result.length > 0) {
                                const element = document.createElement('div');
                                const wrap = document.createElement('div');
                                wrap.classList.add('chart_wrap');
                                element.setAttribute('id', donutChartInfo.element);
                                wrap.appendChild(element);
                                chartsBox.appendChild(wrap);
                                donutChartInfo.data = result;
                            }
                        }
                    });
                });

                donutChartList.forEach((donutChartInfo) => {
                    if(donutChartInfo.data) {
                        const chart = Morris.Donut({
                            data: donutChartInfo.data,
                            element: donutChartInfo.element,
                            redraw: true,
                            resize: false, // 창 크기 변경 시 차트 크기 변경 여부
                            dataLabels: true, // 각 영역 데이터 라벨 표시 여부
                            dataLabelsPosition: 'outside', // 라벨 표시 위치 'inside'/'outside'
                            donutType: 'pie', // 파이 차트로 변경
                            animate: false, // 차트 그리는 애니메이션 재생 여부
                            dataLabelsWeight: '500', // 라벨 font 속성
                            dataLabelsSize: '16px', // 라벨 font 속성
                            dataLabelsColor: '#000', // 라벨 font 속성
                            colors: generateColorShades(donutChartInfo.data.length <= 5 ? donutChartInfo.data.length : 5, "#3980b5", -50),
                            ordering: true,
                        });

                        // 타이틀 글자 맨 위로 보내기
                        const svg = chart.el.querySelector('svg');
                        svg.querySelectorAll('text').forEach(v => svg.appendChild(v));

                    }
                });

                donutChartList.forEach((donutChartInfo) => {
                    if(donutChartInfo.data) {
                        let sum = 0;

                        donutChartInfo.data.forEach((result) => {
                            sum += Number(result.value);
                        });

                        $('#' + donutChartInfo.element).parent('.chart_wrap').append('<div id="' + donutChartInfo.element + '_result" style="font-size: 30px; text-align: center;"> 합계 : ' + sum + '</div>');
                    }
                });
            },
            rowCallback: function (row, data, displayNum, displayIndex, dataIndex) {
                for (var i = 0; i < $(row).children().length; i++) {

                    $('td', row).eq(4).removeClass('hide');
                    $('td', row).eq(5).removeClass('hide');
                }
            },
        });

        // Initalize Select Dropdown after DataTables is created
        $("#result").closest('.dataTables_wrapper').find('select').select2({
            minimumResultsForSearch: -1
        });
    }

    function selectPrelaunchingUserInfo(seq) {
        $("#modal_frame").empty();
        $("#modal_switch").empty();
        $.ajax({
            url: '/event/selectPrelaunchingUserInfo',
            type: 'GET',
            data: {
                seq: seq
            },
            dataType: 'json',
            async: false,
            success: function (prelaunchingUserInfo) {
                $('#modal_seq').val(seq);
                $('#modal_object').val(prelaunchingUserInfo.object).trigger('change');
                $('#modal_email').val(prelaunchingUserInfo.email);
                $('#modal_phone').val(prelaunchingUserInfo.phone);

                jQuery.ajax({
                    type: 'GET',
                    url: '//admin.tbnws.com/event/selectPrelaunchingOption1List',
                    data: {
                        object: object,
                    },
                    dataType: 'json',
                    async: false,
                    success: function (rtn3) {
                        var html = "<option value=''>미선택</option>";

                        for (var i = 0; i < rtn3.length; i++) {
                            html += "<option value='"+ rtn3[i].frame +"'>" + rtn3[i].frame + "</option>";
                        }

                        jQuery("#modal_frame").append(html);
                    }
                });
                if(prelaunchingUserInfo.keyboard_frame != '') {
                    $('#modal_frame').val(prelaunchingUserInfo.keyboard_frame).trigger('change');
                    $('#modal_switch').val(prelaunchingUserInfo.keyboard_switch);
                } else {
                    $('#modal_frame').val(prelaunchingUserInfo.option_1).trigger('change');
                    $('#modal_switch').val(prelaunchingUserInfo.option_2);
                }


                $('div#prelaunchingInfoModal').modal({backdrop: 'static', keyboard: false});
            }, error: function (jqXHR, textStatus, errorThrown) {
                swal("ajax error", "PrelaunchingResult.jsp - selectPrelaunchingUserInfo()", "error");
                console.log(jqXHR.responseText);
                console.log(textStatus);
                console.log(errorThrown);
            }
        });
    }

    function updatePrelaunchingInfo() {
        var seq = $('#modal_seq').val();
        var object = $('#modal_object').val();
        var email = $('#modal_email').val();
        var phone = $('#modal_phone').val();
        var option1 = $('#modal_frame').val();
        var option2 = $('#modal_switch').val();

        if (!object || !email || !phone) {
            alert("프리런칭 종류, 이메일, 연락처를 모두 입력해주세요 !");
            return;
        }

        if (seq) {
            $.ajax({
                url: '/event/updatePrelaunchingInfo',
                type: 'POST',
                data: {
                    seq: seq,
                    object: object,
                    email: email,
                    phone: phone,
                    option1: option1,
                    option2: option2
                },
                async: false,
                success: function (rtn) {
                    if (rtn != -1) {
                        swal({
                            title: "SUCCESS",
                            text: "프리런칭 정보 수정이 완료되었습니다.",
                            type: "success"
                        },
                        function () {
                            $('#prelaunchingInfoModal').modal('hide');
                            setData();
                        });
                    } else {
                        swal({
                            title: "WARNING",
                            text: "알 수 없는 오류가 발생하였습니다.",
                            type: "warning"
                        });
                    }
                }, error: function (jqXHR, textStatus, errorThrown) {
                    swal("ajax error", "PrelaunchingResult.jsp - updatePrelaunchingInfo()", "error");
                    console.log(jqXHR.responseText);
                    console.log(textStatus);
                    console.log(errorThrown);
                }
            });
        }
    }

    function deletePrelaunchingInfo() {
        var seq = $('#modal_seq').val();

        if (seq) {
            swal({
                title: "해당 프리런칭 정보를 삭제하시겠습니까?",
                type: "info",
                showCancelButton: true,
                closeOnConfirm: false,
                confirmButtonText: "삭제",
                confirmButtonColor: "#21a9e1",
                cancelButtonText: "취소"
            }, function () {
                $.ajax({
                    url: '/event/deletePrelaunchingInfo',
                    type: 'POST',
                    data: {
                        seq: seq,
                    },
                    async: false,
                    success: function (rtn) {
                        if (rtn != -1) {
                            swal({
                                title: "SUCCESS",
                                text: "프리런칭 정보 삭제가 완료되었습니다.",
                                type: "success"
                            },
                            function () {
                                $('#prelaunchingInfoModal').modal('hide');
                                setData();
                            });
                        } else {
                            swal({
                                title: "WARNING",
                                text: "알 수 없는 오류가 발생하였습니다.",
                                type: "warning"
                            });
                        }
                    }, error: function (jqXHR, textStatus, errorThrown) {
                        swal("ajax error", "PrelaunchingResult.jsp - deletePrelaunchingInfo()", "error");
                        console.log(jqXHR.responseText);
                        console.log(textStatus);
                        console.log(errorThrown);
                    }
                });
            });
        }
    }


    $(document).ready(function () {
        $('#sb_prelaunching').val('${object}').trigger('change');

        $('#sb_prelaunching').on('change', function () {
            if($('#sb_prelaunching').val() == 'landing') {
                location.href='/event/prelaunchingLandingPage';
            } else {
                setData();
            }
        });

        $("#sms_button").click(function() {
            window.open("/message/sendSMS?object="+object);
        });

        jQuery('#modal_frame').on('change', function() {
            jQuery("#modal_switch").empty();
            var option1 = jQuery("#modal_frame option:selected").val();

            jQuery.ajax({
                type: 'GET',
                url: '//admin.tbnws.com/event/selectPrelaunchingOption2List',
                data: {
                    option1: option1,
                    object: object
                },
                async: false,
                dataType: 'json',
                success: function (rtn) {
                    var html = "<option value=''>미선택</option>";

                    for (var i = 0; i < rtn.length; i++) {
                        html += "<option value='"+ rtn[i].option +"'>" + rtn[i].option + "</option>";
                    }

                    jQuery("#modal_switch").append(html);
                }
            });
        });
    });


    $(window).on("load", function () {
        setData();
    });
</script>

<style>
    .modal .modal-content { -webkit-box-shadow: 0 5px 15px rgba(0, 0, 0, 0.5) !important; box-shadow: 0 5px 15px rgba(0, 0, 0, 0.5) !important; }
    .modal .modal-header .close:not(.display) { display: none; }
    .none { display: none; }
    #prelaunching-charts { display: flex; align-items: center; }
    #prelaunching-charts div.chart_wrap { flex: 1; height: 450px; display: flex; flex-flow: column nowrap; justify-content: space-evenly; }
    #prelaunching-charts div.chart_wrap svg { height: 400px; }
    #prelaunching-charts div.chart_wrap svg text { stroke-opacity: 0.5; stroke: #111; }
</style>

<body class="page-body" data-url="http://neon.dev" onload="onLoad()">

<div class="page-container horizontal-menu">

    <jsp:include page="../header_vertical.jsp" flush="false"/>

    <div class="main-content">
        <jsp:include page="../header_horizontal.jsp" flush="false"/>
        <%--<div class="container"> <!-- 이거 주석처리하면 전체화면 -->--%>
        <div class="row" style="margin-top: 10px;">
            <div class="col-md-12">
                <h2 style="display: inline-block;">프리런칭 현황 상세 페이지</h2>

                <button type="button" id="sms_button" style="float: right; height: 50px; font-size: 19px; font-weight: bold; border: 3px solid; margin-left: 10px;">메세지 발송</button>
                <select id="sb_prelaunching" class="form-control" style="width: 15%; float: right; height: 50px; font-size: 19px; font-weight: bold; border: 3px solid;">
                    <option value="landing">프리런칭 선택</option>
                    <c:forEach var="object" items="${objectList}" varStatus="status">
                        <option value="${object.object}">${object.object}</option>
                    </c:forEach>
                </select>
                <br>

                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-primary">
                            <div id="prelaunching-charts">
<%--                                <div id="autoPrelaunching_chart" class="morrischart"></div>--%>
<%--                                <div id="frame-chart" class="morrischart"></div>--%>
<%--                                <div id="switch-chart" class="morrischart"></div>--%>
                                <%--<div id="count-chart" class="morrischart" style="width: 100% !important;"></div>--%>
                            </div>
                            <table class="table table-bordered hover" id="result"></table>
                        </div>
                    </div>
                </div>

                <!-- Footer -->
                <jsp:include page="../footer.jsp" flush="false"/>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="prelaunchingInfoModal" style="z-index: 10001; overflow-x: hidden; overflow-y: auto;" tabindex="-1" role="dialog">
    <div class="modal-dialog" style="width: 40%;">
        <div class="modal-content">

            <input type="hidden" id="modal_seq">

            <div class="modal-header">
                <button type="button" class="close display" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title" style="font-size: 18px;">프리런칭 정보</h4>
            </div>

            <div class="modal-body">
                <div class="row">
                    <div class="col-md-12">
                        <div class="form-group">
                            <label for="modal_object" class="control-label">프리런칭 종류</label>
                            <select id="modal_object" class="form-control">
                                <option value="">선택</option>
                                <c:forEach var="object" items="${objectList}" varStatus="status">
                                    <option value="${object.object}">${object.object}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modal_email" class="control-label">이메일</label>
                            <input type="text" class="form-control" id="modal_email" placeholder="이메일">
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modal_phone" class="control-label">연락처</label>
                            <input type="text" class="form-control" id="modal_phone" placeholder="연락처">
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modal_frame" class="control-label">옵션1</label>
                            <select class="form-control" id="modal_frame"></select>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modal_switch" class="control-label">옵션2</label>
                            <select class="form-control" id="modal_switch"></select>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-red" onclick="deletePrelaunchingInfo();" style="float: left;">삭제</button>
                <button type="button" class="btn btn-info" onclick="updatePrelaunchingInfo();">저장</button>
                <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>
</body>
</html>
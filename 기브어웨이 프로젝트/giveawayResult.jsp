<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="../head.jsp" flush="false"/>

<jsp:useBean id="date" class="java.util.Date"/>

<head>
    <link href="//cdn.rawgit.com/Eonasdan/bootstrap-datetimepicker/e8bddc60e73c1ec2475f827be36e1957af72e2ea/build/css/bootstrap-datetimepicker.css" rel="stylesheet">
    <script src="//cdn.rawgit.com/Eonasdan/bootstrap-datetimepicker/e8bddc60e73c1ec2475f827be36e1957af72e2ea/src/js/bootstrap-datetimepicker.js"></script>

    <link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote.min.js"></script>
</head>

<script>
    var dataTable;
    var startDate = moment().subtract(6, 'days').format('YYYY-MM-DD');
    var endDate = moment().format('YYYY-MM-DD');

    function setData() {
        var giveawayTitle = $("#sb_event").val();
        var giveaway_count = [];

        if(dataTable != null) dataTable.clear().destroy();

        dataTable = $('#result').DataTable({
            // DataTables - Features
            autoWidth: false,
            processing: true,
            // DataTables - Options
            dom: 'lBfrtip',
            lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]],
            order: [[0,"desc"]],
            // DataTables - Internationalisation
            language: {
                processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw" style="color: #000;"></i><span style="font-size: 2em;">Loading...</span>'
            },
            // Buttons
            buttons: ['copyHtml5', 'excelHtml5', 'csvHtml5'],
            ajax: {
                url:"/event/selectGiveawayUserInfo_DT",
                type:"GET",
                dataType: 'json',
                data: {
                    giveawayTitle: giveawayTitle,
                    startDate : startDate,
                    endDate : endDate
                }
            },
            columns: [
                {
                    className: 'center',
                    data: 'userSeq',
                    render: function(data, type, row, meta) {
                        var rtn = '<a href="javascript:;"';
                        rtn += 'onclick="selectGiveawayInfo(\'' + data + '\');" style="font-weight: bold; font-size: 13px;">';
                        rtn += meta.row + 1;
                        rtn += '</a>';

                        return rtn;
                    },
                    width: '6%'
                },
                {
                    className: 'center',
                    data: 'giveawayTitle',
                },
                {
                    className: 'center',
                    data: 'userPhone'
                },
                {
                    className: 'center',
                    data: 'userEmail'
                },
                {
                    className: 'center',
                    data: 'registDate'
                }
            ],
            // DataTables - Callbacks
            initComplete: function (row, data) {
                var dataList = data.data;
                var total_count = dataList.length;
                var new_count = dataList.filter(e => e.count === 0).length;
                var count_ratio = Math.round((new_count / total_count) * 100);
                var html = '';
                html += '　　총 : ' + total_count + ' / 신규 : ' + new_count + ' (' + count_ratio + '%)';
                $('#count_list').html(html);

                $.ajax({
                    url: '/event/selectGiveawayStates',
                    type: 'GET',
                    data: {
                        giveawayTitle: giveawayTitle,
                        startDate: startDate,
                        endDate: endDate
                    },
                    dataType: 'json',
                    success: function (data) {
                        if(data == "") {
                            $('#giveaway-chart').css("display", "none");
                        } else {
                            for(var i = 0; i < data.length; i++) {

                                $('#giveaway-chart').css("display", "block");
                                giveaway_count.push({
                                    "기준일자": data[i].date,
                                    "카운트": data[i].count,
                                });
                            }
                            // 그래프
                            Morris.Line({
                                element: 'giveaway-chart',
                                data: giveaway_count,
                                xkey: '기준일자',
                                ykeys: ['카운트'],
                                labels: ['카운트'],
                                xLabelAngle: 45,
                                parseTime: false
                            });
                        }

                    }, error: function (jqXHR, textStatus, errorThrown) {
                        swal("ajax error", "giveawayResult.jsp - /event/selectgiveawayStats", "error");
                        console.log(jqXHR.responseText);
                        console.log(textStatus);
                        console.log(errorThrown);
                    }
                });
            }
        });

        // Initalize Select Dropdown after DataTables is created
        $("#result").closest('.dataTables_wrapper').find('select').select2({
            minimumResultsForSearch: -1
        });

        $('.dt-buttons').after
        (
            "<div id='daterange' style='height: 32px; padding: 5px 10px; margin: 10px; cursor: pointer; border: 1px solid #aaa; font-size: 14px; float: left;'>" +
            "<i class='fa fa-calendar' style='margin-right: 5px;'></i>" +
            "<span></span>" +
            "<i class='fa fa-caret-down' style='margin-left: 5px;'></i>" +
            "</div>"
        );

        $('#daterange').daterangepicker({
            startDate: new Date(startDate),
            endDate: new Date(endDate),
            linkedCalendars: false,
            ranges: ranges
        }, function (start, end, label) {
            if (start.toString() != "Invalid date" && end.toString() != "Invalid date") {
                startDate = start.format('YYYY-MM-DD');
                endDate = end.format('YYYY-MM-DD');

                setData();
            }
        });

        setDate(startDate, endDate);

        $('#result_filter').before(
            "<div id='giveaway-chart' class='morrischart' style='height: 300px; position: relative; margin-top: 60px; margin-bottom: 10px;'></div>"
        );
    }

    function setDate(startDate, endDate) {
        $('#daterange span').html(' ' + startDate + ' ~ ' + endDate + ' ');
    }

    function selectGiveawayInfo(giveawaySeq) {
        $.ajax({
            url: '/event/selectGiveawayUserInfo',
            type: 'GET',
            dataType: 'json',
            data: {
                giveawaySeq: giveawaySeq
            },
            async: false,
            success: function (GiveawayInfo) {
                $('#modal_seq').val(giveawaySeq);
                $('#modal_object').val(GiveawayInfo.giveaway_title).trigger('change');
                $('#modal_email').val(GiveawayInfo.user_email);
                $('#modal_phone').val(GiveawayInfo.user_phone);

                $('div#giveawayInfoModal').modal({backdrop: 'static', keyboard: false});
            }, error: function (jqXHR, textStatus, errorThrown) {
                swal("ajax error", "giveawayResult.jsp - selectGiveawayInfo()", "error");
                console.log(jqXHR.responseText);
                console.log(textStatus);
                console.log(errorThrown);
            }
        });
    }

    function deleteGiveawayUserInfo() {
        var seq = $('#modal_seq').val();

        if (seq) {
            swal({
                title: "해당 기브어웨이 참여정보를 삭제하시겠습니까?",
                type: "info",
                showCancelButton: true,
                closeOnConfirm: false,
                confirmButtonText: "삭제",
                confirmButtonColor: "#21a9e1",
                cancelButtonText: "취소"
            }, function () {
                $.ajax({
                    url: '/event/deleteGiveawayUserInfo',
                    type: 'POST',
                    data: {
                        seq: seq,
                    },
                    async: false,
                    success: function (rtn) {
                        if (rtn != -1) {
                            swal({
                                    title: "SUCCESS",
                                    text: "기브어웨이 참여정보 삭제가 완료되었습니다.",
                                    type: "success"
                                },
                                function () {
                                    $('#giveawayInfoModal').modal('hide');
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
                        swal("ajax error", "giveawayResult.jsp - deleteSubscribeInfo()", "error");
                        console.log(jqXHR.responseText);
                        console.log(textStatus);
                        console.log(errorThrown);
                    }
                });
            });
        }
    }

    function updateGiveawayUserInfo() {
        var seq = $('#modal_seq').val();
        var object = $('#modal_object').val();
        var email = $('#modal_email').val();
        var phone = $('#modal_phone').val();

        if (!object || !email || !phone) {
            alert("기브어웨이타이틀 종류, 이메일, 연락처를 모두 입력해주세요 !");
            return;
        }

        if (seq) {
            $.ajax({
                url: '/event/updateGiveawayUserInfo',
                type: 'POST',
                data: {
                    seq: seq,
                    object: object,
                    email: email,
                    phone: phone
                },
                async: false,
                success: function (rtn) {
                    if (rtn != -1) {
                        swal({
                                title: "SUCCESS",
                                text: "기브어웨이 참여정보 수정이 완료되었습니다.",
                                type: "success"
                            },
                            function () {
                                $('#giveawayInfoModal').modal('hide');
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
                    swal("ajax error", "giveawayResult.jsp - updateGiveawayUserInfo()", "error");
                    console.log(jqXHR.responseText);
                    console.log(textStatus);
                    console.log(errorThrown);
                }
            });
        }
    }

    // function updateFlag(data) {
    //     var userSeq = data;
    //     if(userSeq) {
    //         swal({
    //             title: "당첨 처리를 하시겠습니까 ?",
    //             type: "success",
    //             showCancelButton: true,
    //             closeOnConfirm: false,
    //             confirmButtonText: "승인",
    //             confirmButtonColor: "#DD6B55",
    //             cancelButtonText: "취소"
    //         }, function () {
    //             $.ajax({
    //                 url: "/event/updateUserFlag",
    //                 type: "POST",
    //                 data: {
    //                     userSeq: userSeq,
    //                 },
    //                 async: false,
    //                 success: function (rtn) {
    //                     if (rtn >= 0) {
    //                         swal({
    //                                 title: "SUCCESS",
    //                                 text: "당첨 처리가 완료되었습니다.",
    //                                 type: "success"
    //                             },
    //                             function () {
    //                                 setData();
    //                             });
    //                     } else {
    //                         swal({
    //                             title: "WARNING",
    //                             text: "알 수 없는 오류가 발생하였습니다.",
    //                             type: "warning"
    //                         });
    //                     }
    //                 },
    //                 error: function (jqXHR, textStatus, errorThrown) {
    //                     swal("ajax error", "giveawayInfo.jsp - updateFlag()", "error");
    //                     console.log(jqXHR.responseText);
    //                     console.log(textStatus);
    //                     console.log(errorThrown);
    //                 }
    //             });
    //         });
    //     }
    // }

    // function updateCancelFlag(data) {
    //     var userSeq = data;
    //     if(userSeq) {
    //         swal({
    //             title: "당첨 취소를 하시겠습니까 ?",
    //             type: "success",
    //             showCancelButton: true,
    //             closeOnConfirm: false,
    //             confirmButtonText: "승인",
    //             confirmButtonColor: "#DD6B55",
    //             cancelButtonText: "취소"
    //         }, function () {
    //             $.ajax({
    //                 url: "/event/updateCancelFlag",
    //                 type: "POST",
    //                 data: {
    //                     userSeq: userSeq,
    //                 },
    //                 async: false,
    //                 success: function (rtn) {
    //                     console.log(rtn)
    //                     if (rtn >= 0) {
    //                         swal({
    //                                 title: "SUCCESS",
    //                                 text: "취소 처리가 완료되었습니다.",
    //                                 type: "success"
    //                             },
    //                             function () {
    //                                 setData();
    //                             });
    //                     } else {
    //                         swal({
    //                             title: "WARNING",
    //                             text: "알 수 없는 오류가 발생하였습니다.",
    //                             type: "warning"
    //                         });
    //                     }
    //                 },
    //                 error: function (jqXHR, textStatus, errorThrown) {
    //                     swal("ajax error", "giveawayInfo.jsp - updateCancelFlag()", "error");
    //                     console.log(jqXHR.responseText);
    //                     console.log(textStatus);
    //                     console.log(errorThrown);
    //                 }
    //             });
    //         });
    //     }
    // }

    function dateSetting() {
        var startDateString = $('#sb_event option:selected').attr('startDate').split(' ');
        var endDateString = $('#sb_event option:selected').attr('endDate').split(' ');

        var newStartDate = new Date(startDateString[0] + ' ' + startDateString[1] + ' ' + startDateString[2] + ' ' + startDateString[5]);
        var newEndDate = new Date(endDateString[0] + ' ' + endDateString[1] + ' ' + endDateString[2] + ' ' + endDateString[5]);

        startDate = getDate(newStartDate);
        endDate = getDate(newEndDate);
    }


    $(document).ready(function () {
        $('#sb_event').val('${object}').trigger('change');

        if ('${object}' != '') {
            dateSetting();
        }

        $('#sb_event').on('change', function () {
            if($('#sb_event').val() == 'landing') {
                location.href='/event/giveawayLandingPage';
            } else {
                dateSetting();
                setData();
            }
        });
    });

    $(window).on("load", function () {
        setData();
    });

</script>

<body class="page-body" data-url="http://neon.dev" onload="onLoad()">

<div class="page-container horizontal-menu">

    <jsp:include page="../header_vertical.jsp" flush="false"/>

    <div class="main-content">
        <jsp:include page="../header_horizontal.jsp" flush="false"/>

        <div class="row" style="margin-top: 10px;">
            <div class="col-md-12">
                <h2 style="display: inline-block;">기브어웨이 현황 상세 페이지<div id="count_list" style="float: right; font-size: 20px; line-height: 28px;"></div></h2>

                <select id="sb_event" class="form-control"
                        style="width: auto; float: right; height: 50px; font-size: 19px; font-weight: bold; border: 3px solid; margin-left: 5px;">
                    <option value="landing">기브어웨이 선택</option>
                    <c:forEach var="giveawayTitle" items="${giveawayList}" varStatus="status">
                        <option value="${giveawayTitle.object}" startDate="${giveawayTitle.start_date}" endDate="${giveawayTitle.end_date}">${giveawayTitle.giveaway_title}</option>
                    </c:forEach>
                </select>

                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-primary">
                            <table class="table table-bordered hover" id="result">
                                <thead id="thead_main">
                                <tr class="replace-inputs">
                                    <th class="center">번호</th>
                                    <th class="center">제목</th>
                                    <th class="center">참가자 번호</th>
                                    <th class="center">참가자 이메일</th>
                                    <th class="center">참여 일자</th>
                                </tr>
                                </thead>

                                <tbody></tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <jsp:include page="../footer.jsp" flush="false"/>
            </div>
        </div>
    </div>
</div>
<div class="modal fade" id="giveawayInfoModal" style="z-index: 10001; overflow-x: hidden; overflow-y: auto;" tabindex="-1" role="dialog">
    <div class="modal-dialog" style="width: 40%;">
        <div class="modal-content">

            <input type="hidden" id="modal_seq">

            <div class="modal-header">
                <button type="button" class="close display" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title" style="font-size: 18px;">기브어웨이 참여 정보</h4>
            </div>

            <div class="modal-body">
                <div class="row">
                    <div class="col-md-12">
                        <div class="form-group">
                            <label for="modal_object" class="control-label">기브어웨이타이틀 종류</label>
                            <select id="modal_object" class="form-control">
                                <option value="">선택</option>
                                <c:forEach var="giveawayTitle" items="${giveawayList}" varStatus="status">
                                    <option value="${giveawayTitle.object}">${giveawayTitle.giveaway_title}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modal_phone" class="control-label">연락처</label>
                            <input type="text" class="form-control" id="modal_phone" placeholder="연락처">
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modal_email" class="control-label">이메일</label>
                            <input type="text" class="form-control" id="modal_email" placeholder="이메일">
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-red" onclick="deleteGiveawayUserInfo();" style="float: left;">삭제</button>
                <button type="button" class="btn btn-info" onclick="updateGiveawayUserInfo();">저장</button>
                <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>
</body>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="../head.jsp" flush="false"/>

<script type="text/javascript">
    var dataTable;
    var startDate = moment().subtract(6, 'days').format('YYYY-MM-DD');
    var endDate = moment().format('YYYY-MM-DD');
    var chartDate = 'day';

    function setData() {
        var all_prelaunching_list = [];
        var title = [];
        var total_count = 0;

        if(dataTable != null) dataTable.clear().destroy();

        dataTable = $("#result").DataTable({
            // DataTables - Features
            autoWidth: false,
            processing: true,
            // DataTables - Options
            dom: 'lBfrtip',
            lengthMenu: [[-1], ["All"]],
            order:[[2, "desc"]] ,
            // DataTables - Internationalisation
            language: {
                processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw" style="color: #000;"></i><span style="font-size: 2em;">Loading...</span>'
            },
            // Buttons
            buttons: ['copyHtml5', 'excelHtml5', 'csvHtml5'],
            // DataTables - Data
            ajax: {
                url: '/event/selectPrelaunchingList_DT',
                type: 'GET',
                data: {
                },
                dataType: 'json',
            },
            // DataTables - Columns
            columns: [
                {
                    className: 'center',
                    data: 'object',
                    title: '프리런칭 구분',
                    width: '50%'
                },
                {
                    className: 'center',
                    data: 'count',
                    title: '카운트',
                    width: '10%'
                },
                {
                    className: 'center',
                    data: 'startDate',
                    title: '시작일자',
                },
                {
                    className: 'center',
                    data: 'endDate',
                    title: '종료일자',
                    render: function (data, type, row, meta) {
                        var rtn = "";
                        if(data != null) {
                            rtn = data;
                        } else {
                            rtn = "-";
                        }
                        return rtn;
                    }
                }
            ],
            // DataTables - Callbacks
            initComplete: function () {
                // 그래프
                $.ajax({
                    url: '/event/selectPrelaunchingStates',
                    type: 'POST',
                    async: false,
                    data: {
                        startDate: startDate,
                        endDate: endDate,
                        chartDate: chartDate,
                    },
                    dataType: 'json',
                    success: function (json) {
                        var data = json.data;
                        title = ['전체카운트'];
                        for(var i = 0; i < data.length; i++) {
                            var obj = new Object();
                            obj.기준일자 = data[i].date;
                            var titleList = Object.keys(data[i])

                            for (var j = 0; j < titleList.length; j++) {
                                if(!(titleList[j] == 'date' || titleList[j] == 'count')) {
                                    obj[titleList[j]] = data[i][titleList[j]];
                                    if(title.indexOf(titleList[j]) == -1) {
                                        title.push(titleList[j])
                                    }
                                }
                            }
                            obj['전체카운트'] = data[i].count;
                            all_prelaunching_list.push(obj);
                        }

                        var html = "";
                        for(var i = 0; i < title.length; i++) {
                            html += "<span style='display: block;'><input type='checkbox' id='chk_" + title[i] + "' class='chk_title' style='margin: 0 5px;' checked/>" + title[i] + "</span>";
                        }
                        $('#result').before(
                            "<div id='all-prelaunching-chart' class='morrischart' style='height: 300px; position: relative; margin-top: 60px; margin-bottom: 10px;'></div>" +
                            "<div style='float: right;'>" + html + "</div>"
                        );
                    },
                    error: function (jqXHR, textStatus, errorThrown) {
                        swal("ajax error", "prelaunchingLandingPage.jsp - selectPrelaunchingStats()", "error");
                        console.log(jqXHR.responseText);
                        console.log(textStatus);
                        console.log(errorThrown);
                    }
                });

                Morris.Line({
                    element: 'all-prelaunching-chart',
                    data: all_prelaunching_list,
                    xkey: '기준일자',
                    ykeys: title,
                    labels: title,
                    xLabelAngle: 45,
                    parseTime: false,
                    /* 230721 BS - 범례 값 없는 항목 0으로 출력(기존 '-') */
                    hoverCallback: function (index, options, content, row) {
                        let result = '<div class="morris-hover-row-label">' + row['기준일자'] + '</div>';

                        options.labels.forEach((v, i) => {
                            if (row[v]) result += '<div class="morris-hover-point" style="color: ' + options.lineColors[i % 7] + '">\n' + v + ':\n ' + row[v] + "\n</div>";
                            else result += '<div class="morris-hover-point" style="color: ' + options.lineColors[i % 7] + '">\n' + v + ':\n 0\n</div>';
                        });

                        return result;
                    }
                });

                $('.chk_title').on('change', function () {
                    $('#all-prelaunching-chart').empty();
                    var chk_title_list = [];
                    var num = 0;
                    for(var i = 0; i < title.length; i++) {
                        if ($('#chk_' + title[i]).is(":checked")) {
                            chk_title_list[num] = title[i];
                            num++;
                        }
                    }

                    if(chk_title_list.length != 0) {
                        Morris.Line({
                            element: 'all-prelaunching-chart',
                            data: all_prelaunching_list,
                            xkey: '기준일자',
                            ykeys: chk_title_list,
                            labels: chk_title_list,
                            xLabelAngle: 45,
                            parseTime: false
                        });
                    }
                });
            },
            // DataTables - Callbacks
            footerCallback: function (row, data, start, end, display) {
                $('th', row).eq(0).text("합계");

                // Update footer
                $('th', row).eq(1).text(addCommas(total_count));

                total_count = 0;
            },
            rowCallback: function (row, data, displayNum, displayIndex, dataIndex) {
                total_count += data.count;
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

        $('#daterange').after(
            "<div class='dt-buttons' style='display:flex; align-items:center;'>" +
            "<label style='margin-right: 10px; font-size: 13px;'>Grouping</label>" +
            "<a href='javascript:changetime(\"day\");' class='dt-button'>Day</a>" +
            "<a href='javascript:changetime(\"week\");' class='dt-button'>Week</a>" +
            "<a href='javascript:changetime(\"month\");' class='dt-button'>Month</a>" +
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
    }

    function setDate(startDate, endDate) {
        $('#daterange span').html(' ' + startDate + ' ~ ' + endDate + ' ');
    }

    function changetime(date) {
        chartDate = date;
        setData();
    }


    $(document).ready(function () {

        $('#sb_prelaunching').on('change', function () {
            location.href='/event/prelaunchingResult?object=' + $('#sb_prelaunching').val();
        });


    });


    $(window).on("load", function () {
        setData();
    });
</script>

<style>
    .modal .modal-content { -webkit-box-shadow: 0 5px 15px rgba(0, 0, 0, 0.5) !important; box-shadow: 0 5px 15px rgba(0, 0, 0, 0.5) !important; }
    .modal .modal-header .close:not(.display) { display: none; }
</style>

<body class="page-body" data-url="http://neon.dev" onload="onLoad()">

<div class="page-container horizontal-menu">

    <jsp:include page="../header_vertical.jsp" flush="false"/>

    <div class="main-content">
        <jsp:include page="../header_horizontal.jsp" flush="false"/>
        <%--<div class="container"> <!-- 이거 주석처리하면 전체화면 -->--%>
        <div class="row" style="margin-top: 10px;">
            <div class="col-md-12">
                <h2 style="display: inline-block;">프리런칭 현황</h2>

                <select id="sb_prelaunching" class="form-control" style="width: 15%; float: right; height: 50px; font-size: 19px; font-weight: bold; border: 3px solid;">
                    <option value="">프리런칭 선택</option>
                    <c:forEach var="object" items="${objectList}" varStatus="status">
                        <option value="${object.object}">${object.object}</option>
                    </c:forEach>
                </select>
                <br>

                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-primary">
                            <table class="table table-bordered hover" id="result">
                                <tfoot>
                                <tr style="font-size: 13px;">
                                    <th class="center">합계</th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Footer -->
                <jsp:include page="../footer.jsp" flush="false"/>
            </div>
        </div>
    </div>
</div>
</body>
</html>
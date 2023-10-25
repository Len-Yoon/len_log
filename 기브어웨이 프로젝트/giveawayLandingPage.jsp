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
        var all_giveaway_list = [];
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
            order: [3, "desc"],
            // DataTables - Internationalisation
            language: {
                processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw" style="color: #000;"></i><span style="font-size: 2em;">Loading...</span>'
            },
            // Buttons
            buttons: ['copyHtml5', 'excelHtml5', 'csvHtml5'],
            // DataTables - Data
            ajax: {
                url: '/event/selectGiveawayList_DT',
                type: 'GET',
                data: {
                    startDate: startDate,
                    endDate: endDate
                },
                dataType: 'json',
            },
            // DataTables - Columns
            columns: [
                {
                    className: 'center',
                    data: 'giveawayTitle'
                },
                {
                    className: 'center',
                    data: 'giveawayType'
                },
                {
                    className: 'center',
                    data: 'count'
                },
                {
                    className: 'center',
                    data: 'startDate'
                },
                {
                    className: 'center',
                    data: 'endDate'
                }
            ],
            // DataTables - Callbacks
            initComplete: function () {
                // 그래프
                $.ajax({
                    url: '/event/selectGiveawayListStates',
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
                                if(!(titleList[j] == 'date' || titleList[j] == 'count' || titleList[j] == 'giveawayTitle')) {
                                    obj[titleList[j]] = data[i][titleList[j]];
                                    if(title.indexOf(titleList[j]) == -1) {
                                        title.push(titleList[j])
                                    }
                                }
                            }
                            obj['전체카운트'] = data[i].count;
                            all_giveaway_list.push(obj);
                        }

                        var html = "";
                        for(var i = 0; i < title.length; i++) {

                            var id = "chk_";

                            if ($('#sb_giveaway option:contains('+ title[i] +')').val()) {
                                id += $('#sb_giveaway option:contains('+ title[i] +')').val();
                            } else {
                                id += title[i];
                            }

                            html += "<span style='display: block;'><input type='checkbox' id='" + id + "' class='chk_title' style='margin: 0 5px;' checked/>" + title[i] + "</span>";
                        }
                        $('#result').before(
                            "<div id='all-giveaway-chart' class='morrischart' style='height: 300px; position: relative; margin-top: 60px; margin-bottom: 10px;'></div>" +
                            "<div style='float: right;'>" + html + "</div>"
                        );

                    },
                    error: function (jqXHR, textStatus, errorThrown) {
                        swal("ajax error", "giveawayLandingPage.jsp - selectGiveawayListStats()", "error");
                        console.log(jqXHR.responseText);
                        console.log(textStatus);
                        console.log(errorThrown);
                    }
                });

                Morris.Line({
                    element: 'all-giveaway-chart',
                    data: all_giveaway_list,
                    xkey: '기준일자',
                    ykeys: title,
                    labels: title,
                    xLabelAngle: 45,
                    parseTime: false
                });

                $('.chk_title').on('change', function () {
                    $('#all-giveaway-chart').empty();
                    var chk_title_list = [];
                    var num = 0;
                    for(var i = 0; i < title.length; i++) {
                        var id = 'chk_';
                        if ($('#sb_giveaway option:contains('+ title[i] +')').val()) {
                            id += $('#sb_giveaway option:contains('+ title[i] +')').val();
                        } else {
                            id += title[i];
                        }

                        if ($('#' + id).is(":checked")) {
                            chk_title_list[num] = title[i];
                            num++;
                        }
                    }

                    if(chk_title_list.length != 0) {
                        Morris.Line({
                            element: 'all-giveaway-chart',
                            data: all_giveaway_list,
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
                $('th', row).eq(2).text(addCommas(total_count));

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
        $('#sb_giveaway').on('change', function () {
            location.href='/event/giveawayResult?object=' + $('#sb_giveaway').val();
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
                <h2 style="display: inline-block;">기브어웨이 현황</h2>

                <select id="sb_giveaway" class="form-control" style="width: auto; float: right; height: 50px; font-size: 19px; font-weight: bold; border: 3px solid;">
                    <option value="">기브어웨이 선택</option>
                    <c:forEach var="giveaway" items="${giveawayList}" varStatus="status">
                        <option value="${giveaway.object}">${giveaway.giveaway_title}</option>
                    </c:forEach>
                </select>
                <br>

                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-primary">
                            <table class="table table-bordered hover" id="result">
                                <thead id="thead_main">
                                <tr class="replace-inputs">
                                    <th class="center">기브어웨이 구분</th>
                                    <th class="center">기브어웨이 타입</th>
                                    <th class="center">카운트</th>
                                    <th class="center">시작일자</th>
                                    <th class="center">종료일자</th>
                                </tr>
                                </thead>

                                <tbody></tbody>

                                <tfoot>
                                <tr style="font-size: 13px;">
                                    <th class="center">합계</th>
                                    <th></th>
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
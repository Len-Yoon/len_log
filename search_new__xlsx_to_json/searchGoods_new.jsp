<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>

<script>
    var searchTable
    var trafficTable;
    var orderTable;
    var memoDataTable;
    var duty_A;

    var startMemoDate =  moment().subtract(3, 'month').format('YYYY-MM-DD');
    var endMemoDate = moment().format('YYYY-MM-DD');

    var dayType = 'month';
    var dayGradeType = 'day';

    var startGraphDate = moment().subtract(3, 'month').format('YYYY-MM-DD');
    var endGraphDate = moment().format('YYYY-MM-DD');

    var now = new Date();

    var brandCode_A;
    var goodsCode_A;
    var optionCode_A;

    var orderEa = 0;

    var daydiff;

    var search_authorityList = new Array();
    var search_dataTableAuthVisible = new Array();
    var search_dataTableAuthInvisible = new Array();

    function searchGoods_new() {

        if(searchTable != null) searchTable.clear().destroy();

        searchTable = $("#result_search_list").DataTable({
            // DataTables - Features
            autoWidth: false,
            processing: true,
            // DataTables - Options
            dom: 'lBfrtip',
            lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]],
            order: [[2, "asc"], [3, "asc"], [4, "asc"]],
            // DataTables - Internationalisation
            language: {
                processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span style="font-size: 2em;">Loading...</span>'
            },
            // Buttons
            buttons: ['copyHtml5', 'excelHtml5', 'csvHtml5'],
            // DataTables - Data
            ajax: {
                url: "/selectSearchList",
                type: "POST",
                dataType: "json",
            },
            columns: [
                {
                    title: '상품코드 리스트',
                    className: 'center',
                    render: function(data, type, row, meta) {
                        var rtn = "";
                        var code = "";
                        var brandCode = (row.brandCode).replaceAll("brd","");
                        var goodsCode = (row.goodsCode).replaceAll("gs","");
                        var optionCode = "";
                        if(row.optionCode) {
                            optionCode = (row.optionCode).replaceAll("opt","");
                            code = brandCode + "-" + goodsCode + "-" + optionCode;
                        } else {
                            code = brandCode + "-" + goodsCode
                        }

                        rtn += 'G-' + code;
                        rtn += ', F-' + code;

                        return rtn;
                    },
                    visible: false,
                },
                {
                    title: '코드',
                    className: 'center',
                    render: function(data, type, row, meta) {
                        var rtn = "";
                        var brandCode = (row.brandCode).replaceAll("brd","");
                        var goodsCode = (row.goodsCode).replaceAll("gs","");
                        var optionCode = "";
                        if(row.optionCode) {
                            optionCode = (row.optionCode).replaceAll("opt","");
                            rtn = brandCode + "-" + goodsCode + "-" + optionCode;
                        } else {
                            rtn = brandCode + "-" + goodsCode
                        }

                        return rtn;
                    },
                    width: '11%'
                },
                {
                    title: '브랜드',
                    className: 'center',
                    data: 'brandName',

                },
                {
                    title: '상품',
                    className: 'center',
                    data: 'goodsName',
                },
                {
                    title: '옵션',
                    className: 'center',
                    data: 'optionName',
                },
                {
                    title: '통계',
                    className: 'center',
                    render: function(data, type, row, meta) {
                        var goodsName = "[" + row.brandName + "] " + row.goodsName + " " + row.optionName;

                        var rtn = '<button type="button" style="padding: 5px; color: #0b0d0f"';
                        rtn += 'onclick="searchGoodsTrafficInfo(\'' + row.brandCode + '\', \'' + row.goodsCode + '\', \'' + row.optionCode + '\', \'' + row.actualPrice + '\', \'' + row.duty + '\')">보러가기</button>';

                        return rtn;
                    },
                    width: '10%'
                }
            ]
        });

        $("#result_search_list").closest('.dataTables_wrapper').find('select').select2({
            minimumResultsForSearch: -1
        });

        $('div#SearchGoodsModal').modal({backdrop: 'static', keyboard: false});
    }

    function searchGoodsTrafficInfo(brandCode, goodsCode, optionCode, actualPrice, duty) {
        $("#allMemoModal").modal('hide');
        startGraphDate = moment().subtract(3, 'month').format('YYYY-MM-DD');
        endGraphDate = moment().format('YYYY-MM-DD');
        duty_A = duty;

        $('#trafficrange').daterangepicker({
            startDate: new Date(startGraphDate),
            endDate: new Date(endGraphDate),
            linkedCalendars: false,
            ranges: ranges
        }, function (start, end, label) {
            if (start.toString() != "Invalid date" && end.toString() != "Invalid date") {
                startGraphDate = start.format('YYYY-MM-DD');
                endGraphDate = end.format('YYYY-MM-DD');

                $('#trafficrange span').html(' ' + startGraphDate + ' ~ ' + endGraphDate + ' ');

                setGraph();
                setGradeChart();
            }
        });

        dayType = 'month';

        orderEa = 0;

        $("#searchGoodsCode").text('');
        $("#searchGoodsName").text('');
        $("#searchGoodsEa").text(0);
        $("#searchGEa").text(0);
        $("#searchFEa").text(0);
        $("#searchbeDueEaEa").text(0);
        $("#searchLastBuyingPrice").text("0 원");
        $("#searchActualPrice").text("0 원");
        $("#searchLastOrderDate").text('');
        $("#searchDateDiff").text('')
        $("#about").text("약");
        $("#leftEa").html('0 달<br>(약 0 주)');
        $("#searchBuyingPriceInfo").css('display', 'none');
        $("#buyingPriceArea").empty();

        if ('${MemberInfo.admin_flag}' == 'Y' || '${MemberInfo.position}' == '매니저' ||
            '${MemberInfo.part}' == '영업') {
            $(".searchBuyingPriceInfo").css('display', 'table-row');
        }

        daydiff = 0;

        brandCode_A = brandCode;
        optionCode_A = optionCode;
        goodsCode_A = goodsCode;

        var brdCode = brandCode.replaceAll("brd","");
        var gsCode = goodsCode.replaceAll("gs","");
        var optCode = optionCode.replaceAll("opt","");

        if(optCode == "") {
            $("#searchGoodsCode").text(brdCode+"-"+gsCode);
        } else {
            $("#searchGoodsCode").text(brdCode+"-"+gsCode+"-"+optCode);
        }

        $("#searchActualPrice").text(addCommas(actualPrice) + " 원");

        $.ajax({
            url: "/selectTrafficInfo",
            type: "POST",
            dataType: "json",
            data: {
                brandCode: brandCode_A,
                goodsCode: goodsCode_A,
                optionCode: optionCode_A
            },
            async: false,
            success: function (rtn) {

                if(rtn.data[0]) {
                    var allEa = rtn.data[0].g_ea + rtn.data[0].f_ea + rtn.data[0].f_be_due_ea;

                    if(rtn.data[0].g_ea == 0 && rtn.data[0].f_ea == 0) {
                        $("#searchGoodsEa").html('<span style="font-size: 14px; color:#949494; font-weight: bold; float: left; margin-left: 10px; line-height: 70px;">'+ 0 +'</span>');
                        $("#searchGEa").html('<span style="font-size: 14px; color:#949494; font-weight: bold; float: left; margin-left: 10px; line-height: 35px;">지티기어: '+ 0 +'</span>');
                        $("#searchFEa").html('<span style="font-size: 14px; color:#949494; font-weight: bold; float: left; margin-left: 10px; line-height: 35px;">풀필먼트: '+ 0 +'</span>');
                    } else {
                        $("#searchGoodsEa").html('<span style="font-size: 14px; color:#949494; font-weight: bold; float: left; margin-left: 10px; line-height: 70px;">'+ allEa +'</span>');
                        $("#searchGEa").html('<span style="font-size: 14px; color:#949494; font-weight: bold; float: left; margin-left: 10px; line-height: 35px;">지티기어: '+ rtn.data[0].g_ea +'</span>');
                        $("#searchFEa").html('<span style="font-size: 14px; color:#949494; font-weight: bold; float: left; margin-left: 10px; line-height: 35px;">풀필먼트: '+ (rtn.data[0].f_ea + rtn.data[0].f_be_due_ea) +'</span>');
                    }


                    $("#searchDateDiff").text(rtn.data[0].date_diff + " 일 " + "(약 " + Math.round(rtn.data[0].date_diff/7) + "주)");
                    $("#searchLastOrderDate").html(rtn.data[0].order_date + '&nbsp;&nbsp;&nbsp;&nbsp;' + "(입고일:" + '&nbsp;&nbsp;' + rtn.data[0].importDate + ")");

                    $("#searchGoodsName").text(rtn.data[0].goodsName);

                    daydiff = rtn.data[0].date_diff;

                    if(rtn.data[0].orderSeq) {
                        $.ajax({
                            url: "/selectOrderTableInfo",
                            type: "POST",
                            dataType: "json",
                            data: {
                                orderSeq: rtn.data[0].orderSeq
                            },
                            async: false,
                            success: function (rtn2) {
                                orderEa = rtn.data[0].g_be_due_ea;

                                if(rtn.data[0].g_be_due_ea != 0) {
                                    if(rtn2.arrDate != '') {
                                        if(rtn2.arrFlag == 'Y') {
                                            $("#searchbeDueEaEa").text(rtn.data[0].g_be_due_ea + "  (" + rtn2.arrDate +" 입고 확정)");
                                        } else {
                                            $("#searchbeDueEaEa").text(rtn.data[0].g_be_due_ea + "  (" +  rtn2.arrDate +" 입고 예정)");
                                        }
                                    } else {
                                        if(daydiff) {
                                            var importDay = new Date(rtn.data[0].order_date);
                                            importDay.setDate(importDay.getDate() + daydiff);

                                            var year = importDay.getFullYear();
                                            var month = importDay.getMonth() +1;
                                            if(month < 10) {
                                                month = "0"+month;
                                            }
                                            var day =  importDay.getDate();
                                            if(day < 10) {
                                                day = "0"+day
                                            }

                                            $("#searchbeDueEaEa").text(rtn.data[0].g_be_due_ea + "  (" + year + "-" + month + "-" + day +" 입고 예정)");
                                        } else {
                                            var importDay = new Date(rtn.data[0].order_date);
                                            importDay.setDate(importDay.getDate() + 42);

                                            var year = importDay.getFullYear();
                                            var month = importDay.getMonth() +1;
                                            if(month < 10) {
                                                month = "0"+month;
                                            }
                                            var day =  importDay.getDate();
                                            if(day < 10) {
                                                day = "0"+day
                                            }
                                            $("#searchbeDueEaEa").text(rtn.data[0].g_be_due_ea + "  (" + year + "-" + month + "-" + day +" 입고 예정)");
                                        }
                                    }
                                } else {
                                    $("#searchbeDueEaEa").text(0);
                                }
                            }
                        })
                    } else {
                        $("#searchbeDueEaEa").text(0);
                    }

                    $.ajax({
                        url: "/selectBuyingPriceInfo",
                        type: "POST",
                        dataType: "json",
                        data: {
                            brandCode: brandCode_A,
                            goodsCode: goodsCode_A,
                            optionCode: optionCode_A
                        },
                        async: false,
                        success: function (rtn3) {

                            if(rtn3.data.length > 0) {
                                var html = '';
                                html += '<span id="buyingPrice" style="font-size: 14px; font-weight: bold; color: #949494;">'
                                for(var i = 0; i < rtn3.data.length; i++) {
                                    if(rtn3.data[i].currency == 'USD' || rtn3.data[i].currency == 'EUR') {
                                        html += rtn3.data[i].orderDate + '&nbsp;&nbsp;&nbsp;' + rtn3.data[i].buyingPrice +'&nbsp;' + rtn3.data[i].currency + '&nbsp;&nbsp;&nbsp;' + addCommas((Math.round(rtn3.data[i].buyingPrice * rtn3.data[i].cur2krw * (1.25 + (duty * 0.01)) * 10))/10) +"원"+ " (부가세 포함)<br>";
                                    } else {
                                        html += rtn3.data[i].orderDate + '&nbsp;&nbsp;&nbsp;' + addCommas(Math.round(rtn3.data[i].buyingPrice * 1.1)) +"원"+ " (부가세 포함)<br>";
                                    }
                                }
                                html += '</span>';
                                html += '<button class="searchBuyingPriceInfo" onclick="orderHistory()">더 보기</button>';

                                $("#buyingPriceArea").append(html);
                            } else {

                            }
                        }
                    });

                }
            },
            error: function (jqXHR, textStatus, errorThrown) {
                swal("ajax error", "searchGoods.jsp - selectTrafficInfo()", "error");
                console.log(jqXHR.responseText);
                console.log(textStatus);
                console.log(errorThrown);
            }
        });
        setGrade();
        setGraph();
        setGoodsMemo(brandCode, goodsCode, optionCode);

        $('div#trafficInfoModal').modal({backdrop: 'static', keyboard: false});
    }

    function setGoodsMemo(brandCode, goodsCode, optionCode) {
        if (memoDataTable != null) memoDataTable.clear().destroy();

        memoDataTable = $("#memo_list").DataTable({
            // DataTables - Features
            autoWidth: false,
            processing: true,
            // DataTables - Options
            dom: 'lBfrtip',
            lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]],
            order: [3, "desc"],
            // DataTables - Internationalisation
            language: {
                processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw" style="color: #000;"></i><span style="font-size: 2em;">Loading...</span>'
            },
            // Buttons
            buttons: ['copyHtml5', 'excelHtml5', 'csvHtml5'],
            ajax: {
                url: '/selectMemo_DT',
                type: 'GET',
                data: {
                    brandCode: brandCode,
                    goodsCode: goodsCode,
                    optionCode: optionCode
                },
            },
            // DataTables - Columns
            columns: [
                {
                    className: 'center',
                    data: 'seq',
                    render: function(data, type, row, meta) {
                        var rtn = '';

                        rtn = '<a href="javascript:;"';
                        rtn += ' onclick="showGoodsMemoInfo(\'' + data + '\');"';
                        rtn += ' style="font-weight: bold;">';
                        rtn +=  data;
                        rtn += '</a>';

                        return rtn;
                    },
                    width: '10%',
                    title: "번호"
                },
                {
                    className: 'center',
                    data: 'memo',
                    width: '50%',
                    title: "메모"
                },
                {
                    className: 'center',
                    data: 'name',
                    width: '10%',
                    title: "작성자"
                },
                {
                    className: 'center',
                    data: 'registDate',
                    width: '30%',
                    title: "작성일자"
                }
            ],
        });

        // Initalize Select Dropdown after DataTables is created
        $("#memo_list").closest('.dataTables_wrapper').find('select').select2({
            minimumResultsForSearch: -1
        });
    }

    function showGoodsMemoInfo(seq) {
        $('#goods_memo_seq').val('');
        $('#goods_memo_contents').val('');
        $('#goods_btn_delete').css("display", "none");
        $('#goods_btn_save').css("display", "inline-block");
        $('#goods_btn_edit').css("display", "none");

        if(seq) {
            $('#goods_memo_seq').val(seq);
            $('#goods_btn_save').css("display", "none");
            $('#goods_btn_delete').css("display", "inline-block");
            $('#goods_btn_edit').css("display", "inline-block");

            $.ajax({
                url: '/selectGoodsMemoInfo',
                type: 'POST',
                dataType: 'json',
                data: {
                    seq: seq
                },
                async: false,
                success: function (goodsMemoInfo) {
                    if (goodsMemoInfo) {
                        $('#goods_memo_contents').val(goodsMemoInfo.memo);
                        $('#goods_btn_edit').css("display", "inline-block");

                    } else {
                        swal({
                            title: "WARNING",
                            text: "알 수 없는 오류가 발생하였습니다.",
                            type: "warning"
                        });
                    }
                }, error: function (jqXHR, textStatus, errorThrown) {
                    swal("ajax error", "searchGoods.jsp - selectGoodsMemoInfo()", "error");
                    console.log(jqXHR.responseText);
                    console.log(textStatus);
                    console.log(errorThrown);
                }
            });

        }

        $('div#goodsMemoInfoModal').modal({backdrop: 'static', keyboard: false});
    }

    function deleteGoodsMemoInfo() {
        var seq = $('#goods_memo_seq').val();

        $.ajax({
            url: '/deleteGoodsMemoInfo',
            type: 'POST',
            data: {
                seq: seq
            },
            async: false,
            success: function (rtn) {
                if(rtn != -1) {
                    swal({
                            title: "SUCCESS",
                            text: "메모가 삭제되었습니다.",
                            type: "success"
                        },
                        function () {
                            memoDataTable.ajax.reload(null, false);
                            $('#goodsMemoInfoModal').modal('hide');
                        });
                }
            }
        });
    }

    function saveGoodsMemoInfo() {
        var searchGoodsCode = $('#searchGoodsCode').text();

        searchGoodsCode = searchGoodsCode.split('-');

        var brandCode = '';
        var goodsCode = '';
        var optionCode = '';

        brandCode = 'brd' + searchGoodsCode[0];
        goodsCode = 'gs' + searchGoodsCode[1];
        if(searchGoodsCode.length == 3) {
            optionCode = 'opt' + searchGoodsCode[2];
        }

        var contents = $('#goods_memo_contents').val();

        if (!contents) {
            alert("내용을 입력해주세요");
            return;
        }

        $.ajax({
            url: '/insertGoodsMemoInfo',
            type: 'POST',
            data: {
                brandCode: brandCode,
                goodsCode: goodsCode,
                optionCode: optionCode,
                memo: contents
            },
            async: false,
            success: function (rtn) {
                if(rtn != -1) {
                    swal({
                            title: "SUCCESS",
                            text: "메모 등록이 완료되었습니다.",
                            type: "success"
                        },
                        function () {
                            memoDataTable.ajax.reload(null, false);
                            $('#goodsMemoInfoModal').modal('hide');
                        });
                }
            }
        });
    }

    function editGoodsMemoInfo() {
        var seq = $('#goods_memo_seq').val();
        var memo = $('#goods_memo_contents').val();

        $.ajax({
            url: '/editGoodsMemoInfo',
            type: 'POST',
            data: {
                seq: seq,
                memo: memo
            },
            async: false,
            success: function (rtn) {
                if(rtn != -1) {
                    swal({
                            title: "SUCCESS",
                            text: "메모가 수정되었습니다.",
                            type: "success"
                        },
                        function () {
                            memoDataTable.ajax.reload(null, false);
                            $('#goodsMemoInfoModal').modal('hide');
                        });
                }
            }
        });
    }

    function setGrade() {
        $("#grade").text('');
        $("#eaText").text('');
        $("#availableMonth").html('');
        $("#leftEa").css("font-size","38px");

        $.ajax({
            url: '/selectGoodsGrade',
            type: 'POST',
            data: {
                brandCode: brandCode_A,
                goodsCode: goodsCode_A,
                optionCode: optionCode_A,
            },
            dataType: 'json',
            success: function (rtn) {

                var grade = '';
                if (rtn.availableMonth <= 0) grade = "X";
                else if (rtn.availableMonth < 3) grade = "A";
                else if (rtn.availableMonth < 6) grade = "B";
                else if (rtn.availableMonth < 12) grade = "C";
                else if (rtn.availableMonth < 24) grade = "D";
                else if (rtn.availableMonth < 50) grade = "E";
                else if (rtn.availableMonth < 100) grade = "F";
                else grade = "G";

                $("#grade").text(grade);
                $("#grade").css("margin-top", "30px");
                $("#searchMonthAvg").text((Math.round(rtn.threeMonthEa / 3 * 10) / 10));


                $("#availableMonth").html("<div id='orderStatus' style='border:1px solid black; border-radius: 50%; height: 100px; width: 100px; background-color: green; margin: auto;'><div id='eaText' style='color: white;'></div></div>")

                if (rtn.availableMonth == -1) {
                    $("#leftEa").html(" ∞<br>개월");
                    rtn.availableMonth = 999;
                } else {

                    $("#leftEa").html(" " + Math.round(rtn.availableMonth * 10) / 10 + "<br>개월");
                }

                if(orderEa != 0) {
                    $("#leftEa").html(" " + Math.round(rtn.availableMonth * 10) / 10 + "<br>개월");
                    $("#orderStatus").css("background-color", "#73e600");
                    $("#eaText").text("입고 예정");
                } else {
                    if(rtn.ea == 0) {
                        $("#orderStatus").css("background-color", "black");
                        $("#eaText").text("재고 없음");
                        $("#leftEa").html("-");
                        $("#grade").text("-")
                        $("#grade").css("margin-top", "0px");
                        $("#about").text("");
                        $("#leftEa").css("font-size","110px");
                    } else {
                        if ((Math.round(rtn.availableMonth * 10) / 10) <= 0) {
                            $("#orderStatus").css("background-color", "red");
                            $("#eaText").text("발주 필요");
                        } else {
                            if (((Math.round(rtn.availableMonth * 10) / 10) > (Math.round(daydiff / 30) * 2))) {
                                $("#orderStatus").css("background-color", "green");
                                $("#eaText").text("재고 충분");
                            } else {
                                var marginDate = (Math.round(rtn.availableMonth * 10) / 10) - (Math.round(daydiff / 30));
                                if(marginDate > 0) {
                                    $("#orderStatus").css("background-color", "orange");
                                    $("#eaText").html(Math.round(marginDate) + "주 이내<br>발주 필요");
                                } else {
                                    $("#orderStatus").css("background-color", "red");
                                    $("#eaText").text("발주 필요");
                                }
                            }
                        }
                    }
                }


                // if (ea == 0) {
                //     $("#orderStatus").css("background-color", "black");
                //     $("#eaText").text("재고 없음");
                //     $("#leftEa").html("-");
                //     $("#about").text("");
                //     $("#ggrade").text("-")
                // } else if (rtn.availableWeek > 0 && (rtn.availableWeek > (Math.round(daydiff / 7) * 2))) {
                //     $("#orderStatus").css("background-color", "green");
                //     $("#eaText").text("재고 충분");
                //
                // } else if (rtn.availableWeek > 0 && (rtn.availableWeek) < (Math.round(daydiff / 7) * 2)) {
                //     $("#orderStatus").css("background-color", "orange");
                //     var availableWeek = Math.round(ea / rtn.availableWeek) - Math.round(daydiff / 7);
                //     $("#eaText").html(availableWeek + "주 이내<br>발주 필요");
                //
                // } else if {
                //     $("#orderStatus").css("background-color", "red");
                //     $("#eaText").text("발주 필요");
                // }

            }
        });


        setGradeChart();
    }

    function orderHistory() {
        var curDate = getDate(new Date());

        if ('${MemberInfo.admin_flag}' == 'Y' || '${MemberInfo.position}' == '매니저'
            || '${MemberInfo.part}' == '영업') {
            search_authorityList = ['발주번호', '매입처', '발주제목', '발주일자', '입고수량', '사입가(부가세 미포함)', '수입원가(부가세 포함)(관세 포함)', '진행상태'];
        } else {
            search_authorityList = ['발주번호', '매입처', '발주제목', '발주일자', '진행상태'];
        }



        if (orderTable != null) orderTable.clear().destroy();

        orderTable = $("#result_order_history").DataTable({
            // DataTables - Features
            autoWidth: false,
            processing: true,
            // DataTables - Options
            dom: 'lBfrtip',
            lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]],
            order: [[0, "desc"]],
            // DataTables - Internationalisation
            language: {
                processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span style="font-size: 2em;">Loading...</span>'
            },
            // Buttons
            buttons: [
                {
                    extend: 'copyHtml5',
                    exportOptions: {
                        columns: search_dataTableAuthVisible
                    }
                },
                {
                    extend: 'excelHtml5',
                    exportOptions: {
                        columns: search_dataTableAuthVisible
                    }
                },
                {
                    extend: 'csvHtml5',
                    charset: 'UTF-8',
                    bom: true,
                    exportOptions: {
                        columns: search_dataTableAuthVisible
                    }
                },
            ],
            // DataTables - Data
            ajax: {
                url: "/searchGoodsOrder",
                type: "POST",
                data: {
                    brandCode: brandCode_A,
                    goodsCode: goodsCode_A,
                    optionCode: optionCode_A
                },
                dataType: "json",
            },
            columns: [
                {
                    title: '발주번호',
                    className: 'center',
                    data: 'orderSeq',
                    render: function(data, type, row, meta) {
                        var rtn = '';
                        rtn += '<a href="/erp/goodsOrder?orderSeq=' + data + '"';
                        rtn += ' target="_blank" ';
                        rtn += ' style="font-weight: bold;">';
                        rtn += data;
                        rtn += '</a>';

                        return rtn;
                    },
                    width: '8%'
                },
                {
                    title: '매입처',
                    className: 'center',
                    data: 'partnerName',
                },
                {
                    title: '발주제목',
                    className: 'center',
                    data: 'orderTitle'
                },
                {
                    title: '발주일자',
                    className: 'center',
                    data: 'orderDate'
                },
                {
                    title: '입고수량',
                    className: 'center',
                    data: 'ea'
                },
                {
                    title: '사입가<br>(부가세 미포함)',
                    data: 'buyingPrice',
                    render: function(data, type, row, meta) {

                        var rtn = '';
                        if(row.currency == 'KRW') {
                            rtn = addCommas(Math.round(data)) + ' 원';
                        } else {
                            rtn = data + " " + row.currency;
                        }

                        return rtn;
                    }
                },
                {
                    title: '수입원가<br>(부가세 포함)<br>(관세 포함)',
                    render: function(data, type, row, meta) {
                        var rtn;
                        if(row.currency == 'KRW') {
                            rtn = addCommas(Math.round((row.buyingPrice * 1.1) * 10) / 10) + ' 원';
                        } else {
                            rtn = addCommas(Math.round((row.buyingPrice * (1.25 + (duty_A * 0.01)) * row.cur2krw) * 10) / 10) + ' 원';
                        }

                        return rtn;
                    }
                },
                {
                    className: 'center',
                    title: '진행상태',
                    render: function(data, type, row, meta) {
                        var rtn = '';


                        var orderStatus;
                        if (curDate < row.orderDate) orderStatus = 0;
                        else orderStatus = 1;

                        var depStatus;
                        if (row.depFlag == 'N') depStatus = 0;
                        else depStatus = 1;

                        var arrStatus;
                        if (row.arrFlag == 'N') arrStatus = 0;
                        else arrStatus = 1;

                        var clearanceStatus;
                        if (row.clearanceConfirmEa == 0) clearanceStatus = 0;
                        else if (row.clearanceConfirmEa < row.totalImportEa) clearanceStatus = 1;
                        else clearanceStatus = 2;

                        var importStatus;
                        if (row.importedEa == 0) importStatus = 0;
                        else if (row.importedEa < row.totalImportEa) importStatus = 1;
                        else importStatus = 2;

                        var saleStatus;
                        if (row.saleConfirmEa == 0) saleStatus = 0;
                        else if (row.saleConfirmEa < row.totalImportEa) saleStatus = 1;
                        else saleStatus = 2;

                        if(orderStatus = 0) {
                            rtn = '발주예정';
                        } else if (orderStatus = 1 && depStatus == 0) {
                            rtn = '운송출발예정';
                        } else if (orderStatus = 1 && depStatus == 1 && arrStatus == 0) {
                            rtn = '운송도착예정';
                        } else if (orderStatus = 1 && depStatus == 1 && arrStatus == 0 && clearanceStatus == 0) {
                            rtn = '통관확인';
                        } else if (orderStatus = 1 && depStatus == 1 && arrStatus == 0 && clearanceStatus == 1) {
                            rtn = '부분통관확인';
                        } else if (orderStatus = 1 && depStatus == 1 && arrStatus == 0 && clearanceStatus == 2 && importStatus == 0) {
                            rtn = '입고확인';
                        } else if (orderStatus = 1 && depStatus == 1 && arrStatus == 0 && clearanceStatus == 2 && importStatus == 1) {
                            rtn = '부분입고완료';
                        } else if (orderStatus = 1 && depStatus == 1 && arrStatus == 0 && clearanceStatus == 2 && importStatus == 2 && saleStatus == 0) {
                            rtn = '판매확인';
                        } else if (orderStatus = 1 && depStatus == 1 && arrStatus == 0 && clearanceStatus == 2 && importStatus == 2 && saleStatus == 1) {
                            rtn = '부분판매확인';
                        } else {
                            rtn = '판매확인완료';
                        }

                        return rtn;
                    }
                }
            ],
            headerCallback: function (thead, data, start, end, display) {
                $(thead).find('th').each(function (index) {
                    $(this).addClass('center');
                });

                if(search_dataTableAuthInvisible.length == 0 && search_dataTableAuthVisible.length == 0) {
                    $(thead).find('th').each(function (index) {
                        if(!search_authorityList.includes($(this).text())) {
                            search_dataTableAuthInvisible.push(index);
                            $(this).css('display', 'none');
                        } else {
                            search_dataTableAuthVisible.push(index);
                        }
                    });
                }
            },
            rowCallback: function (row, data, displayNum, displayIndex, dataIndex) {
                $('td', row).eq(5).css('text-align', 'right');
                $('td', row).eq(6).css('text-align', 'right');

                for (var i = 0; i < search_dataTableAuthInvisible.length; i++) {
                    $(row).children().eq(search_dataTableAuthInvisible[i]).css('display', 'none');
                }
            },
        });


        $("#result_order_history").closest('.dataTables_wrapper').find('select').select2({
            minimumResultsForSearch: -1
        });

        $('div#OrderHistoryModal').modal({backdrop: 'static', keyboard: false});
    }

    function setGraph() {
        $("#morris_chart").empty();

        var chartAllList = [];

        $.ajax({
            url: '/selectTrafficChart',
            type: 'POST',
            data: {
                brandCode: brandCode_A,
                goodsCode: goodsCode_A,
                optionCode: optionCode_A,
                startGraphDate: startGraphDate,
                endGraphDate: endGraphDate,
                dayType: dayType

            },
            dataType: 'json',
            success: function (rtn) {
                for (var i = 0; i < rtn.length; i++) {
                    chartAllList.push({
                        '전체판매량': rtn[i].gTrafficCount + rtn[i].fTrafficCount,
                        '지티기어판매량': rtn[i].gTrafficCount,
                        '풀필먼트판매량': rtn[i].fTrafficCount,
                        '판매날짜': rtn[i].day
                    });
                }

                setTimeout( function () {
                    Morris.Line({
                        element: 'morris_chart',
                        data: chartAllList,
                        parseTime: false,
                        xkey: "판매날짜",
                        ykeys: ["전체판매량","지티기어판매량","풀필먼트판매량"],
                        labels: ["전체판매량","지티기어판매량","풀필먼트판매량"],
                        xLabelAngle: 45,
                        redraw: true,
                        parseTime: false,
                        smooth: false
                    });
                }, 500);

            }
        });

        $('#trafficrange span').html(' ' + startGraphDate + ' ~ ' + endGraphDate + ' ');
    }

    function setGradeChart() {
        $("#grade_chart").empty();

        var chartGradeList = [];

        $.ajax({
            url: '/selectGradeGraph',
            type: 'POST',
            datatype: "json",
            data: {
                brandCode: brandCode_A,
                goodsCode: goodsCode_A,
                optionCode: optionCode_A,
                startGradeDate: startGraphDate,
                endGradeDate: endGraphDate,
                dayGradeType: dayType
            },
            dataType: 'json',
            success: function (rtn) {
                if(rtn) {
                    for (var i = 0; i < rtn.length; i++) {
                        var grade_num = "";
                        var availableMonth = rtn[i].availableMonth;
                        var date = rtn[i].day;

                        if (availableMonth <= 0) grade_num = 1;
                        else if (availableMonth < 3) grade_num = 8;
                        else if (availableMonth < 6) grade_num = 7;
                        else if (availableMonth < 12) grade_num = 6;
                        else if (availableMonth < 24) grade_num = 5;
                        else if (availableMonth < 50) grade_num = 4;
                        else if (availableMonth < 100) grade_num = 3;
                        else grade_num = 2;

                        chartGradeList.push({
                            '등급': grade_num,
                            '날짜': date
                        });
                    }

                    setTimeout( function () {
                        Morris.Line({
                            element: 'grade_chart',
                            data: chartGradeList,
                            parseTime: false,
                            xkey: "날짜",
                            ykeys: ["등급"],
                            labels: ["등급"],
                            xLabelAngle: 45,
                            redraw: true,
                            smooth: false,
                            ymax: 8,
                            ymin: 1,
                            yLabelFormat: function (x) {
                                if(x ==  8) return 'A';
                                else if (x == 7) return 'B';
                                else if (x == 6) return 'C';
                                else if (x == 5) return 'D';
                                else if (x == 4) return 'E';
                                else if (x == 3) return 'F';
                                else if (x == 2) return 'G';
                                else if (x == 1) return 'X';
                                else return "";
                            }
                        });
                    }, 500);
                }
            }
        });
    }

    function changeGraphtime(rtn) {
        dayType = rtn;
        setGraph();
        setGradeChart();
    }

    function getStartDateFromISOWeek(weekDate) {
        var y = parseInt(weekDate.substring(0, 4));
        var w = parseInt(weekDate.substring(5, 7));

        var simpleDate = new Date(y, 0, 1 + (w - 1) * 7);
        var dayOfWeek = simpleDate.getDay();
        var weekDateStart = simpleDate;

        if (dayOfWeek <= 4) {
            weekDateStart.setDate(simpleDate.getDate() - simpleDate.getDay() + 1);
        }
        else {
            weekDateStart.setDate(simpleDate.getDate() + 8 - simpleDate.getDay());
        }
        var weekDateEnd = weekDateStart;
        weekDateEnd.setDate(weekDateStart.getDate() + 6);

        return weekDateEnd;
    }

    function dateFormat(date) {
        var date = new Date(date)

        var year = date.getFullYear();
        var month = ('0' + (date.getMonth() + 1)).slice(-2);
        var day = ('0' + date.getDate()).slice(-2);
        date = year + '-' + month + '-' + day;

        return date;
    }

    function showExcelUploadModal() {
        $("#inputFile2").val("");

        $('#excelUploadModal #excelUpload').off().on('click', function () {
            if (!$("#inputFile2").val()) {
                swal({
                    title: "WARNING",
                    text: "엑셀 파일을 선택 해주세요.",
                    type: "warning"
                });
            }
            else {
                var inputFile2 = document.getElementById('inputFile2');

                var formData = new FormData();
                formData.append("file", inputFile2.files[0]);
                formData.append("sheetNum", "0");

                $.ajax({
                    url: '/erp/xlsx2json',
                    type: 'POST',
                    data: formData,
                    async: false,
                    processData: false,
                    contentType: false,
                    dataType: 'json',
                    success: function (data) {
                        insertSearchMemoInfo(data);
                    },
                    error: function (jqXHR, textStatus, errorThrown) {
                        swal("ajax error", "searchGoods_new.jsp - xlsx2json()", "error");
                        console.log(jqXHR.responseText);
                        console.log(textStatus);
                        console.log(errorThrown);
                    }
                });
            }
        });

        $('#excelUploadModal').modal({backdrop: 'static', keyboard: false});
    }

    function insertSearchMemoInfo(data) {
        var total = 0;
        var cnt = 0;

        swal({
            title: "상품 메모를 추가하시겠습니까?",
            text: "상품코드 확인 필수 !!!",
            type: "info",
            showCancelButton: true,
            closeOnConfirm: false,
            confirmButtonText: "확인",
            confirmButtonColor: "#21a9e1",
            cancelButtonText: "닫기",
        }, function () {

            for (var i = 1; i < data.length; i++) {
                if (data[i].length == 0) continue;

                var code = data[i][0];
                if (code == undefined || code == "") continue;

                var codeList = code.split("-");
                if (codeList.length < 3) continue;

                var brandCode = "brd" + codeList[0];
                var goodsCode = "gs" + codeList[1];
                var optionCode = "";
                if (codeList.length > 3) {
                    optionCode = "opt" + codeList[2];
                }

                total++;

                $.ajax({
                    url: '/insertGoodsMemoInfo',
                    type: 'POST',
                    data: {
                        brandCode: brandCode,
                        goodsCode: goodsCode,
                        optionCode: optionCode,
                        memo: data[i][1]
                    },
                    async: false,
                    success: function (rtn) {
                        if(rtn != -1) {
                            swal({
                                    title: "SUCCESS",
                                    text: "메모 등록이 완료되었습니다.",
                                    type: "success"
                                },
                                function () {
                                    $('#excelUploadModal').modal('hide');
                                    showMemoLog();
                                });
                        }
                    }
                });
            }
        });
    }

    function showMemoLog() {
        $("#reportrange_seach").val("");
        if(memoDataTable != null) {
            memoDataTable.destroy();
        }

        memoDataTable = $("#result_memo_log").DataTable({
            // DataTables - Features
            autoWidth: false,
            processing: true,
            // DataTables - Options
            dom: 'lBfrtip',
            lengthMenu: [[10, 25, 50], [10, 25, 50]],
            order: [[4, "desc"]],
            // DataTables - Internationalisation
            language: {
                processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw" style="color: #000;"></i><span style="font-size: 2em;">Loading...</span>'
            },
            // Buttons
            buttons: ['copyHtml5', 'excelHtml5', 'csvHtml5'],
            // DataTables - Data
            ajax: {
                url: '/selectAllSearchMemoList',
                type: 'GET',
                data: {
                    startMemoDate: startMemoDate,
                    endMemoDate: endMemoDate
                }
            },
            // DataTables - Columns
            columns: [
                {
                    className: 'center',
                    data: 'code',
                    title: '상품 코드',
                    width: '10%',
                    render: function(data, type, row, meta) {
                        var rtn;
                        rtn = '<a href="javascript:;"';
                        rtn += ' onclick="searchGoodsTrafficInfo(\'' + row.brandCode + '\', \'' + row.goodsCode + '\', \'' + row.optionCode + '\', \'' + 0 + '\', \'' + 0 + '\')"';
                        rtn += ' style="font-weight: bold;">';
                        rtn += data;
                        rtn += '</a>';

                        return rtn;
                    },
                },
                {
                    className: 'center',
                    data: 'goodsName',
                    title: '상품명',
                },
                {
                    className: 'center',
                    data: 'memo',
                    title: '메모 내용',
                    render: function(data, type, row, meta) {
                        var rtn = '';
                        if (data.length > 50) {
                            rtn = '<a href="javascript:;"';
                            rtn += 'onclick="showMemoContent(\'' + data.replaceAll("\n","@") + '\')" ';
                            rtn += 'style = "font-weight: bolder;">';
                            rtn +=  data.substring(0,50) + '...';
                            rtn += '</a>';
                        } else {
                            rtn +=  data;
                        }

                        return rtn;
                    },
                },
                {
                    className: 'center',
                    data: 'name',
                    title: '이름',
                    width: '7%'
                },
                {
                    className: 'center',
                    data: 'registDate',
                    title: '등록일',
                    width: '10%'
                },

            ]
        });

        $('#result_memo_log_wrapper .dt-buttons').after(
            "<div id='reportrange_seach' style='height: 32px; padding: 5px 10px; margin: 10px; cursor: pointer; border: 1px solid #aaa; font-size: 14px; float: left;'>" +
            "<i class='fa fa-calendar' style='margin-right: 5px;'></i>" +
            "<span></span>" +
            "<i class='fa fa-caret-down' style='margin-left: 5px;'></i>" +
            "</div>"
        );

        // Initalize Select Dropdown after DataTables is created
        $("#result_memo_log").closest('.dataTables_wrapper').find('select').select2({
            minimumResultsForSearch: -1
        });

        $('#reportrange_seach').daterangepicker({
            startMemoDate: new Date(startMemoDate),
            endMemoDate: new Date(endMemoDate),
            linkedCalendars: false,
            ranges: ranges
        }, cb_search);

        $('#reportrange_seach span').html(' ' + startMemoDate + ' ~ ' + endMemoDate + ' ');

        // Show Modal
        $('div#allMemoModal').modal({backdrop: 'static', keyboard: false});
    }

    function cb_search(start, end) {
        if (start.toString() != "Invalid date" && end.toString() != "Invalid date") {
            startMemoDate = start.format('YYYY-MM-DD');
            endMemoDate = end.format('YYYY-MM-DD');
            // memoDataTable.ajax.reload(null, false);
            showMemoLog();
        }
    }

    function showMemoContent(data) {
        var data2 = data.replaceAll("@", "<br>").toString();

        $("#html_content2").html(data2);

        $('#showSearchMemoModal').modal({backdrop: 'static', keyboard: false});
    }

    $(document).ready(function () {
        $('#dayType').select2();
        $('#ref-year').select2();
        $('#end-year').select2();


        var thisDate;
        $('#trafficInfoModal').on('click', '#morris_chart svg', function() {
            // Find data and date in the actual morris diply below the graph.
            thisDate = $(".morris-hover-row-label").html();

            var startDate;
            var endDate;

            if(dayType == 'day') {
                startDate = thisDate;
                endDate = thisDate;
            } else if (dayType == 'week') {
                endDate = getStartDateFromISOWeek(thisDate);
                endDate = dateFormat(endDate.setDate(endDate.getDate() - 1));
                startDate = new Date(endDate);
                startDate = dateFormat(startDate.setDate(startDate.getDate() - 6));

            } else {

                startDate = dateFormat(moment(thisDate).startOf('month'));
                endDate = dateFormat(moment(thisDate).endOf('month'));
            }

            window.open('/erp/goodsStatus?categoryCode=G&brandCode='+ brandCode_A + '&goodsCode=' + goodsCode_A + '&optionCode=' + optionCode_A + '&dateType=' + dayType + '&startDate=' + startDate + '&endDate=' + endDate + '&search=Y','_blank')
        });
    });

</script>

<style>
    .select2-drop {
        z-index: 99999;
    }

    .daterangepicker {
        z-index: 99999;
    }

    #SearchGoodsModal {
        z-index: 99999;
    }

    #eaText {
        font-size: 15px;
        position: relative;
        top: 50%;
        transform: translateY(-50%);
    }

    .sweet-alert, .swal-overlay {
        z-index: 99999999999;
    }

    .show-calendar {
        z-index: 9999999999;
    }

    .select2-drop-active{
        z-index: 999999999;
    }

    @media (max-width: 1500px) {
        #firstModal { width:  90% !important;}
        #secondModal { width: 80% !important;}
    }



</style>

<body>

<div class="modal fade" id="SearchGoodsModal" style="z-index: 10002; overflow-x: hidden; overflow-y: auto;">
    <div class="modal-dialog" id="firstModal" style="width: 60%; box-shadow: 0px 0px 100px 0px black;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title" style="float: left; margin-top: 10px; margin-right: 10px;">상품검색</h4>

                <button type="button" class="topButton" style="float: left;" onclick="showMemoLog()">메모 보기</button>
            </div>

            <div class="modal-body">
                <div class="row">
                    <div class="col-md-12">
                        <div id="return_list_table" class="row">
                            <div class="col-md-12">
                                <div class="panel panel-primary">
                                    <table class="table table-bordered hover" id="result_search_list"></table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="trafficInfoModal" style="z-index: 10002; overflow-x: hidden; overflow-y: auto;">
    <div class="modal-dialog" id="secondModal" style="width: 70%; box-shadow: 0px 0px 100px 0px black;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close display" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title" style="font-size: 18px;">상품 통계</h4>
            </div>

            <div class="modal-body">
                <div class="row">
                    <div class="col-md-5">
                        <table class="table table-bordered hover extra" style="margin-bottom: 0px; border: 1px;">
                            <tbody>
                            <tr>
                                <td class="center" style="font-size: 14px; width: 32%"><label class="control-label" style="float: left; margin-left: 10px;">상품코드</label></td>
                                <td style="font-size: 14px;"><label id="searchGoodsCode" class="control-label"></label></td>
                            </tr>

                            <tr>
                                <td class="center" style="font-size: 14px;"><label class="control-label" style="float: left; margin-left: 10px;">상품명</label></td>
                                <td style="font-size: 14px;"><label id="searchGoodsName" class="control-label"></label></td>
                            </tr>

                            <tr style="height: 70px;">
                                <td class="center" style="font-size: 14px;"><label class="control-label" style="float: left; margin-left: 10px;">현재 재고</label></td>
                                <td style="font-size: 14px; padding: 0px;" id="eaArea">
                                    <div style="width: 40%; height: 70px; border-right: 1px solid #ebebeb; float: left;">
                                        <div id="searchGoodsEa"></div>
                                    </div>
                                    <div style="width: 60%; float: right">
                                        <div id="searchGEa" style="height: 35px; border-bottom: 1px solid #ebebeb; font-size: 14px; color:#333;"></div>
                                        <div id="searchFEa" style="font-size: 14px; color:#333;"></div>
                                    </div>
                                </td>
                            </tr>

                            <tr>
                                <td class="center" style="font-size: 14px;"><label class="control-label" style="float: left; margin-left: 10px;">입고 예정 재고</label></td>
                                <td style="font-size: 14px;"><label id="searchbeDueEaEa" class="control-label"></label></td>
                            </tr>

                            <tr>
                                <td class="center" style="font-size: 14px;"><label class="control-label" style="float: left; margin-left: 10px;">월평균 판매수량</label></td>
                                <td style="font-size: 14px;"><label id="searchMonthAvg" class="control-label"></label></td>
                            </tr>

                            <tr>
                                <td class="center" style="font-size: 14px;"><label class="control-label" style="float: left; margin-left: 10px;">판매 가격 (공식몰)</label></td>
                                <td style="font-size: 14px;"><label id="searchActualPrice" class="control-label"></label></td>
                            </tr>

                            <tr>
                                <td class="center" style="font-size: 14px;"><label class="control-label" style="float: left; margin-left: 10px;">최근 수입 원가<br>(관세 포함)</label></td>
                                <td style="font-size: 13px; color:#333;" id="buyingPriceArea"></td>
                            </tr>

                            <tr>
                                <td class="center" style="font-size: 14px;"><label class="control-label" style="float: left; margin-left: 10px;">마지막 발주일</label></td>
                                <td style="font-size: 14px; font-weight: bold; color: #949494;"><label id="searchLastOrderDate" class="control-label"></label></td>
                            </tr>

                            <tr>
                                <td class="center" style="font-size: 14px;"><label class="control-label" style="float: left; margin-left: 10px;">최근 발주 리드타임<br>(마지막 입고일 기준)</label></td>
                                <td style="font-size: 14px;"><label id="searchDateDiff" class="control-label"></label></td>
                            </tr>
                            </tbody>
                        </table>

                        <div class="row" style="margin-top: 10px">
                            <div class="col-md-4" style="text-align: center;">
                                <label class="form-label" style="font-size: 14px;">최근 판매 등급</label>
                                <div id="grade" style="font-size: 110px; line-height: 50px; margin-top: 30px;"></div>
                            </div>

                            <div class="col-md-4" style="text-align: center;">
                                <label class="form-label" style="font-size: 14px;">현재고 유지</label>
                                <div style="line-height: 50px;" ><span id="about">약 </span><span style="font-size: 38px;" id="leftEa"></span></div>
                            </div>

                            <div class="col-md-4" style="text-align: center;">
                                <label class="form-label" style="font-size: 14px;">발주 필요 상태</label>
                                <div id="availableMonth">
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-7">
                        <div class="row">
                            <div>
                                <h4 style="font-weight: bold; margin-top: 18px; float: left;">판매량 차트</h4>
                                <div id='trafficrange' style='height: 32px; padding: 5px 10px; margin: 10px; cursor: pointer; border: 1px solid #aaa; font-size: 14px; float: left;'>
                                    <i class='fa fa-calendar'></i><span></span><i class='fa fa-caret-down'></i>
                                </div>

                                <div class="graph_button" style='display:inline-flex; align-items:center; height: 32px; margin: 10px;'>
                                    <label style='margin-right: 10px; font-size: 13px;'>Grouping</label>
                                    <a href='javascript:changeGraphtime("day");' class='dt-button' style="display: inline; ">Day</a>
                                    <a href='javascript:changeGraphtime("week");' class='dt-button' style="display: inline;">Week</a>
                                    <a href='javascript:changeGraphtime("month");' class='dt-button' style="display: inline;">Month</a>
                                </div>
                            </div>
                        </div>

                        <div class="row" style="margin-top: 15px;">
                            <div id='morris_chart' class='morrischart' style='position: relative; height: 250px;'></div>
                        </div>

                        <div class="row">
                            <div>
                                <h4 style="font-weight: bold; margin-top: 18px; float: left;">등급 차트</h4>
                            </div>
                        </div>

                        <div class="row" style="margin-top: 15px;">
                            <div id='grade_chart' class='morrischart' style='position: relative; height: 250px'></div>
                        </div>
                    </div>
                </div>

                <div class="row" style="margin-top: 20px;">
                    <div class="col-md-12">
                        <div style="font-weight: bold; color: black; font-size: 20px; margin-bottom: 10px; float: left;">상품 메모</div>
                        <button type="button" style="color: #000000; font-size: 15px; margin-left: 15px; margin-bottom: 20px; vertical-align: super;" onclick="showGoodsMemoInfo()">+ 메모 등록</button>
                    </div>

                    <div class="col-md-12">
                        <table class="table table-bordered hover" id="memo_list"></table>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="OrderHistoryModal" style="z-index: 999999; overflow-x: hidden; overflow-y: auto; ">
    <div class="modal-dialog" style="width: 70%; box-shadow: 0px 0px 100px 0px black;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">발주 히스토리</h4>
            </div>

            <div class="modal-body">
                <div class="row">
                    <div class="col-md-12">
                        <div class="col-md-12">
                            <div class="panel panel-primary">
                                <table class="table table-bordered hover" id="result_order_history"></table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="goodsMemoInfoModal" style="z-index: 99999; overflow-x: hidden; overflow-y: auto;" tabindex="-1" role="dialog">
    <div class="modal-dialog" style="box-shadow: 0 0 30px;">
        <div class="modal-content">

            <input type="hidden" id="goods_memo_seq">

            <div class="modal-header">
                <button type="button" class="close display" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title" style="font-size: 18px;">
                    메모 등록
                </h4>
            </div>

            <div class="modal-body">
                <div class="row">
                    <div class="col-md-12">
                        <div class="form-group">
                            <label for="goods_memo_contents" class="control-label">메모 내용</label>
                            <textarea id="goods_memo_contents" style="width: 100%; height: 300px;"></textarea>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-red" onclick="deleteGoodsMemoInfo();" id="goods_btn_delete" style="float: left; display: none;">삭제</button>
                <button type="button" class="btn btn-info" onclick="saveGoodsMemoInfo();" id="goods_btn_save">저장</button>
                <button type="button" class="btn btn-info" onclick="editGoodsMemoInfo()" id="goods_btn_edit" style="display:none;">수정</button>
                <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="excelUploadModal" style="z-index: 9999999999; box-shadow: 0px 0px 100px 0px black;  overflow-x: hidden; overflow-y: auto;" role="dialog">
    <div class="modal-dialog" style="width: 30%; box-shadow: 0px 0px 100px 0px black;">
        <div class="modal-content">

            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title" style="font-size: 18px;">메모 다중 등록</h4>
            </div>

            <div class="modal-body">

                <div class="row">
                    <div class="col-md-12">
                        <div class="form-group">
                            <h4 style="float: left">엑셀파일 업로드</h4>

                            <a href="//file.tbnws.com/upload/admin/sample/search_memo_sample.xlsx" class="MemoSample">
                                <i class="fa fa-download" style="float: left; font-size: 15px; font-weight: bold; margin: 8px 20px;"> Sample</i>
                            </a>
                        </div>
                    </div>

                    <div class="col-md-12" style="margin-top: 25px;">
                        <div class="form-group">
                            <input type="file" id="inputFile2"/>
                        </div>
                    </div>
                </div>

                <button type="button" class="btn btn-blue" id="excelUpload">저장</button>
                <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="allMemoModal" style="z-index: 999999999; overflow-x: hidden; overflow-y: auto;">
    <div class="modal-dialog" style="width: 90%; box-shadow: 0px 0px 100px 0px black;">
        <div class="modal-content">

            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title" style="float: left; margin-top: 10px;">상품검색 메모내역</h4>
                <button type="button" class="topButton" style="float: left;" onclick="showExcelUploadModal()">+ 다중 메모</button>
            </div>

            <div class="modal-body">
                <div class="row">
                    <div class="col-md-12">
                        <div id="sms_log_list_table" class="row">
                            <div class="col-md-12">
                                <div class="panel panel-primary">
                                    <table class="table table-bordered hover" id="result_memo_log"></table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="showSearchMemoModal" style="z-index: 9999999999;">
    <div class="modal-dialog" style="box-shadow: 0px 0px 100px 0px black;">
        <div class="modal-content">

            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">메모 내용</h4>
            </div>

            <div class="modal-body" id="html_content2"></div>

            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

</body>

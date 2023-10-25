

<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<jsp:include page="../head.jsp" flush="false"/>

<jsp:useBean id="date" class="java.util.Date"/>

<head>
    <link href="//cdn.rawgit.com/Eonasdan/bootstrap-datetimepicker/e8bddc60e73c1ec2475f827be36e1957af72e2ea/build/css/bootstrap-datetimepicker.css" rel="stylesheet">
    <script src="//cdn.rawgit.com/Eonasdan/bootstrap-datetimepicker/e8bddc60e73c1ec2475f827be36e1957af72e2ea/src/js/bootstrap-datetimepicker.js"></script>
</head>

<script type="text/javascript">
    var dataTable;
    var messageObject;

    function setData() {
        if(dataTable != null) dataTable.clear().destroy();

        dataTable = $("#result").DataTable({
            // DataTables - Features
            autoWidth: false,
            processing: true,
            // DataTables - Options
            dom: 'lBfrtip',
            lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]],
            // DataTables - Internationalisation
            language: {
                processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw" style="color: #000;"></i><span style="font-size: 2em;">Loading...</span>'
            },
            order: [[8,"asc"],[0, "desc"]],
            // Buttons
            buttons: ['copyHtml5', 'excelHtml5', 'csvHtml5'],
            ajax: {
                url: "/event/selectPreLaunchingList_DT",
                type: 'GET',
                dataType: 'json',
            },
            columns: [
                {
                    className: "center",
                    data: "preLaunchingSeq",
                    title: '번호',
                },
                {
                    className: "center",
                    data: "preLaunchingTtile",
                    render: function(data, type, row, meta) {
                        var rtn = '<a href="javascript:;"';
                        rtn += ' onclick="showPreLaunchingEvent(\'' + row.preLaunchingSeq + '\');"';
                        rtn += ' style="font-weight: bold;">';
                        rtn += data;
                        rtn += '</a>';

                        return rtn;
                    },
                    title: '제목',
                },
                {
                    className: "center",
                    data: "object",
                    title: '고유 URL',
                },
                {
                    className: "center",
                    data: "startDate",
                    title: '사작일자',
                },
                {
                    className: "center",
                    data: "endDate",
                    render: function (data, type, row, meta) {
                        var rtn = "-";
                        if(data != "") {
                            rtn = data;
                        }
                        return rtn;
                    },
                    title: '종료일자',
                },
                {
                    className: "center",
                    data: "buyStartDate",
                    render: function (data, type, row, meta) {
                        var rtn = "-";
                        if(data != "") {
                            rtn = data;
                        }
                        return rtn;
                    },
                    title: '예약구매 시작일자',
                },
                {
                    className: "center",
                    data: "buyEndDate",
                    render: function (data, type, row, meta) {
                        var rtn = "-";
                        if(data != "") {
                            rtn = data;
                        }
                        return rtn;
                    },
                    title: '예약구매 종료일자',
                },
                {
                    className: "center",
                    data: "registDate",
                    title: '등록일시',
                },
                {
                    className: "center",
                    render: function (data, type, row, meta) {
                        var startDate = new Date(row.startDate + ' 00:00:00');
                        var endDate = new Date(row.endDate + ' 23:59:59');
                        var now = new Date();

                        var rtn = "<div style='font-weight: bolder;"
                        if(endDate != null && endDate < now) {
                            rtn += " color: Black;'><div style='display: none'>3</div>종료</div>"
                        } else if (now < startDate) {
                            rtn += " color: Blue;'><div style='display: none'>2</div>예정</div>"
                        } else {
                            rtn += " color: Red;'><div style='display: none'>1</div>진행 중</div>"
                        }

                        return rtn;
                    },
                    title: '상태',
                },
                {
                    className: "center",
                    render: function (data, type, row, meta) {
                        var rtn = "";

                        rtn += '<button type="button" onclick="window.open(\'/event/prelaunchingResult?object=';
                        rtn += row.object;
                        rtn += '\');" style="padding: 5px; color: #0b0d0f">';
                        rtn += '보러가기';
                        rtn += '</button>';

                        return rtn;
                    },
                    title: '현황',
                }
            ],
            // DataTables - Callbacks
            headerCallback: function (thead, data, start, end, display) {
                $(thead).find('th').each(function (index) {
                    $(this).addClass('center');
                });
            },
        });

        $("#result").closest('.dataTables_wrapper').find('select').select2({
            minimumResultsForSearch: -1
        });
    }

    function showPreLaunchingEvent(preLaunchingSeq) {
        $("#preLaunching_seq").val("");
        $("#preLaunchingTitle").val("");
        $("#object").val("");
        $("#url").val("");
        $("#startDate").val("");
        $("#endDate").val("");
        $("#buyStartDate").val("");
        $("#buyEndDate").val("");
        $("#addRowCategory").empty();
        $("#addRowGift").empty();
        $("#addRowOption").empty();
        $("#addRowSubscribe").empty();
        $("#deletePreLaunchingEvent").hide();
        $('[name=edit_category]').val("").trigger('change');
        $("#object").attr("readonly", false);

        if(preLaunchingSeq) {
            $("#preLaunching_seq").val(preLaunchingSeq);
            $("#deletePreLaunchingEvent").show();
            $("#object").attr("readonly", true);
            $("#url").attr("readonly", true);

            $.ajax({
                url: "/event/selectPreLaunchingListDetail",
                type: "POST",
                data: {
                    preLaunchingSeq: preLaunchingSeq
                },
                async: false,
                dataType: 'json',
                success: function (rtn) {
                    $("#preLaunchingTitle").val(rtn.preLaunchingTitle);
                    $("#object").val(rtn.object);
                    $("#startDate").val(rtn.startDate);
                    $("#endDate").val(rtn.endDate);
                    $("#buyStartDate").val(rtn.buyStartDate);
                    $("#buyEndDate").val(rtn.buyEndDate);
                    $("#url").val(rtn.url);

                    $.ajax({
                        url: "/event/selectPreLaunchingListDetailItem",
                        type: "POST",
                        data: {
                            preLaunchingSeq: preLaunchingSeq
                        },
                        async: false,
                        dataType: 'json',
                        success: function (itemRtn) {
                            $.each(itemRtn, function(idx, value) {
                                if(value.preLaunchingType == "P") {
                                    // addRowCategory();
                                    //
                                    // $('[name=edit_category]').last().val(value.categoryCode).trigger('change');
                                    // $('[name=edit_brand]').last().val(value.brandCode).trigger('change');
                                    // $('[name=edit_goods]').last().val(value.goodsCode).trigger('change');
                                    // $('[name=edit_option]').last().val(value.optionCode).trigger('change');

                                    $('[name=edit_category]').val(value.categoryCode).trigger('change');
                                    $('[name=edit_brand]').val(value.brandCode).trigger('change');
                                    $('[name=edit_goods]').val(value.goodsCode).trigger('change');
                                } else {
                                    addRowGift();

                                    $('[name=edit_gift_category]').last().val(value.categoryCode).trigger('change');
                                    $('[name=edit_gift_brand]').last().val(value.brandCode).trigger('change');
                                    $('[name=edit_gift_goods]').last().val(value.goodsCode).trigger('change');
                                    $('[name=edit_gift_option]').last().val(value.optionCode).trigger('change');
                                }
                            });
                        }
                    });

                    $.ajax({
                        url: "/event/selectPreLaunchingOptionList",
                        type: "POST",
                        data: {
                            object: rtn.object
                        },
                        async: true,
                        dataType: 'json',
                        success: function (optionRtn) {
                            $.each(optionRtn, function(idx, value) {
                                addRowOption();

                                $('[name=option1]').last().val(value.option1);
                                $('[name=option2]').last().val(value.option2);
                            });
                        }
                    });

                    $.ajax({
                        url: "/event/selectPrelaunchingSubscribeItem",
                        type: "POST",
                        data: {
                            object: rtn.object
                        },
                        async: true,
                        dataType: 'json',
                        success: function (subscribeRtn) {
                            $.each(subscribeRtn, function(idx, value) {
                                addRowSubscribe();

                                $('[name=imageUrl]').last().val(value.imageUrl);
                            });
                        }
                    });
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    swal("ajax error", "preLaunchingList.jsp - selectPreLaunchingListDetailItem()", "error");
                    console.log(jqXHR.responseText);
                    console.log(textStatus);
                    console.log(errorThrown);
                }
            });
        }

        $('#showPreLaunchingEvent').modal({backdrop: 'static', keyboard: false});
    }

    function savePreLaunchingEvent() {
        var preLaunchingSeq = $("#preLaunching_seq").val();
        var preLaunchingTitle = $("#preLaunchingTitle").val();
        var object = $("#object").val();
        var url = $("#url").val();
        var startDate = $("#startDate").val();
        var endDate = $("#endDate").val();
        var buyStartDate = $("#buyStartDate").val();
        var buyEndDate = $("#buyEndDate").val();
        var categoryCode = $('[name=edit_category] option:selected').val();
        var brandCode = $('[name=edit_brand] option:selected').val();
        var goodsCode = $('[name=edit_goods] option:selected').val();

        var checkValidation1 = true;

        if(categoryCode && (!brandCode || !goodsCode)) {
            checkValidation1 = false;
        }

        if(checkValidation1 == false) {
            swal("WARNING", "상품 선택 정보를 모두 입력해 주세요 !", "warning");
            return;
        }

        var checkValidation2 = true;

        $('div[type=addList_gift_category]').each(function () {
            var categoryCode_gift = $(this).find('[name=edit_gift_category] option:selected').val();
            var brandCode_gift = $(this).find('[name=edit_gift_brand] option:selected').val();
            var goodsCode_gift = $(this).find('[name=edit_gift_goods] option:selected').val();
            var optionCode_gift = $(this).find('[name=edit_gift_option] option:selected').val();

            if(!categoryCode_gift || !brandCode_gift || !goodsCode_gift) {
                checkValidation2 = false;
            } else if (!$(this).find('select[name=edit_gift_option]').prop('disabled') && !optionCode_gift) {
                checkValidation2 = false;
            } else if (!buyStartDate || !buyEndDate) {
                checkValidation2 = false;
            }
        });

        if(checkValidation2 == false) {
            swal("WARNING", "사은품 정보와 예약구매 일정을 확인 주세요 !", "warning");
            return;
        }

        if(preLaunchingTitle == "") {
            swal("WARNING", "프리런칭 제목을 입력해 주세요 !", "warning");
        } else if (object == "") {
            swal("WARNING", "고유 URL을 입력해 주세요 !", "warning");
        } else if (startDate == "") {
            swal("WARNING", "시작일자를 입력해 주세요 !", "warning");
        } else if (endDate && (startDate > endDate)) {
            swal("WARNING", "시작일자와 종료일자를 확인해 주세요 !", "warning");
        } else if (buyEndDate && (buyStartDate > buyEndDate)) {
            swal("WARNING", "예약구매 시작일자와 예약구매 종료일자를 확인해 주세요 !", "warning");
        } else {
            if(!preLaunchingSeq) {
                swal({
                    title: "해당 프리런칭을 저장하시겠습니까?",
                    type: "info",
                    showCancelButton: true,
                    closeOnConfirm: false,
                    confirmButtonText: "확인",
                    confirmButtonColor: "#21a9e1",
                    cancelButtonText: "닫기",
                }, function () {
                    //저장
                    $.ajax({
                        url: "/event/insertPreLaunchingList",
                        type: "POST",
                        data: {
                            preLaunchingTitle: preLaunchingTitle,
                            object: object,
                            startDate: startDate,
                            endDate: endDate,
                            buyStartDate : buyStartDate,
                            buyEndDate : buyEndDate,
                            url: url,
                            brandCode: brandCode
                        },
                        async: false,
                        dataType: 'json',
                        success: function (preLaunchingSeq) {
                            var c = true;

                            if(preLaunchingSeq) {

                                if (categoryCode) {
                                    $.ajax({
                                        url: "/event/insertPreLaunchingListItem",
                                        type: "POST",
                                        data: {
                                            preLaunchingSeq: preLaunchingSeq,
                                            preLaunchingType: "P",
                                            categoryCode: categoryCode,
                                            brandCode: brandCode,
                                            goodsCode: goodsCode,
                                            optionCode: ""
                                        },
                                        async: false,
                                        dataType: 'json',
                                        success: function(rtn) {
                                            if(rtn == -1) {
                                                c = false;
                                            }
                                        }
                                    });
                                }

                                $('div[type=addList_gift_category]').each(function () {
                                    var categoryCode = $(this).find('[name=edit_gift_category] option:selected').val();
                                    var brandCode = $(this).find('[name=edit_gift_brand] option:selected').val();
                                    var goodsCode = $(this).find('[name=edit_gift_goods] option:selected').val();
                                    var optionCode = $(this).find('[name=edit_gift_option] option:selected').val();

                                    $.ajax({
                                        url: "/event/insertPreLaunchingListItem",
                                        type: "POST",
                                        data: {
                                            preLaunchingSeq: preLaunchingSeq,
                                            preLaunchingType: "G",
                                            categoryCode: categoryCode,
                                            brandCode: brandCode,
                                            goodsCode: goodsCode,
                                            optionCode: optionCode
                                        },
                                        async: false,
                                        dataType: 'json',
                                        success: function(rtn) {
                                            if(rtn == -1) {
                                                c = false;
                                            }
                                        }
                                    });
                                });

                                $('div[type=addList_option_category]').each(function () {
                                    var option1 = $(this).find('input[name=option1]').val();
                                    var option2 = $(this).find('input[name=option2]').val();

                                    $.ajax({
                                        url: "/event/insertPrelauchingOption",
                                        type: "POST",
                                        data: {
                                            object: object,
                                            option1: option1,
                                            option2: option2,
                                            type: 'insert'
                                        },
                                        async: false,
                                        dataType: 'json',
                                        success: function(rtn) {
                                            if(rtn == -1) {
                                                c = false;
                                            }
                                        }
                                    });
                                });

                                $('div[type=addList_subscribe_category]').each(function () {
                                    var imageUrl = $(this).find('input[name=imageUrl]').val();

                                    $.ajax({
                                        url: "/event/insertPrelaunchingSubscribeItem",
                                        type: "POST",
                                        data: {
                                            object: object,
                                            imageUrl: imageUrl,
                                            type: 'insert'
                                        },
                                        async: false,
                                        dataType: 'json',
                                        success: function(rtn) {
                                            if(rtn == -1) {
                                                c = false;
                                            }
                                        }
                                    });
                                });

                                if(c == true) {
                                    swal({
                                            title: "SUCCESS",
                                            text: "프리런칭 정보를 저장하였습니다.",
                                            type: "success"
                                    },
                                    function () {
                                        dataTable.ajax.reload(null, false);
                                        $('#showPreLaunchingEvent').modal('hide');
                                    });
                                } else {
                                    swal("WARNING", "프리런칭 저장을 실패하였습니다.", "warning");
                                }
                            } else {
                                swal("WARNING", "프리런칭 저장을 실패하였습니다.", "warning");
                            }
                        }
                    });
                });
            } else {
                swal({
                    title: "해당 프리런칭을 수정하시겠습니까?",
                    type: "info",
                    showCancelButton: true,
                    closeOnConfirm: false,
                    confirmButtonText: "확인",
                    confirmButtonColor: "#21a9e1",
                    cancelButtonText: "닫기",
                }, function () {
                    $.ajax({
                        url: "/event/updatePreLaunchingList",
                        type: "POST",
                        data: {
                            preLaunchingSeq: preLaunchingSeq,
                            preLaunchingTitle: preLaunchingTitle,
                            object: object,
                            startDate: startDate,
                            endDate: endDate,
                            buyStartDate : buyStartDate,
                            buyEndDate : buyEndDate,
                            url: url,
                            brandCode: brandCode
                        },
                        async: false,
                        dataType: 'json',
                        success: function (rtn) {
                            if(rtn != -1) {
                                var c = true;

                                var categoryCode = $('[name=edit_category] option:selected').val();
                                var brandCode = $('[name=edit_brand] option:selected').val();
                                var goodsCode = $('[name=edit_goods] option:selected').val();

                                if (categoryCode) {
                                    $.ajax({
                                        url: "/event/insertPreLaunchingListItem",
                                        type: "POST",
                                        data: {
                                            preLaunchingSeq: preLaunchingSeq,
                                            preLaunchingType: "P",
                                            categoryCode: categoryCode,
                                            brandCode: brandCode,
                                            goodsCode: goodsCode,
                                            optionCode: ""
                                        },
                                        async: false,
                                        dataType: 'json',
                                        success: function(rtn) {
                                            if(rtn == -1) {
                                                c = false;
                                            }
                                        }
                                    });
                                }

                                $('div[type=addList_gift_category]').each(function () {
                                    var categoryCode = $(this).find('[name=edit_gift_category] option:selected').val();
                                    var brandCode = $(this).find('[name=edit_gift_brand] option:selected').val();
                                    var goodsCode = $(this).find('[name=edit_gift_goods] option:selected').val();
                                    var optionCode = $(this).find('[name=edit_gift_option] option:selected').val();

                                    $.ajax({
                                        url: "/event/insertPreLaunchingListItem",
                                        type: "POST",
                                        data: {
                                            preLaunchingSeq: preLaunchingSeq,
                                            preLaunchingType: "G",
                                            categoryCode: categoryCode,
                                            brandCode: brandCode,
                                            goodsCode: goodsCode,
                                            optionCode: optionCode
                                        },
                                        async: false,
                                        dataType: 'json',
                                        success: function(rtn) {
                                            if(rtn == -1) {
                                                c = false;
                                            }
                                        }
                                    });
                                });

                                $('div[type=addList_option_category]').each(function () {
                                    var option1 = $(this).find('input[name=option1]').val();
                                    var option2 = $(this).find('input[name=option2]').val();

                                    $.ajax({
                                        url: "/event/insertPrelauchingOption",
                                        type: "POST",
                                        data: {
                                            object: object,
                                            option1: option1,
                                            option2: option2,
                                            type: 'update'
                                        },
                                        async: false,
                                        dataType: 'json',
                                        success: function(rtn) {
                                            if(rtn == -1) {
                                                c = false;
                                            }
                                        }
                                    });
                                });

                                $('div[type=addList_subscribe_category]').each(function () {
                                    var imageUrl = $(this).find('input[name=imageUrl]').val();

                                    $.ajax({
                                        url: "/event/insertPrelaunchingSubscribeItem",
                                        type: "POST",
                                        data: {
                                            object: object,
                                            imageUrl: imageUrl
                                        },
                                        async: false,
                                        dataType: 'json',
                                        success: function(rtn) {
                                            if(rtn == -1) {
                                                c = false;
                                            }
                                        }
                                    });
                                });

                                if(c == true) {
                                    swal({
                                            title: "SUCCESS",
                                            text: "프리런칭 정보를 수정하였습니다.",
                                            type: "success"
                                    },
                                    function () {
                                        dataTable.ajax.reload(null, false);
                                        $('#showPreLaunchingEvent').modal('hide');
                                    });
                                } else {
                                    swal("WARNING", "프리런칭 수정을 실패하였습니다.", "warning");
                                }
                            } else {
                                swal("WARNING", "프리런칭 수정을 실패하였습니다.", "warning");
                            }
                        }
                    });
                });
            }
        }
    }

    function deletePreLaunchingEvent() {
        var preLaunchingSeq = $("#preLaunching_seq").val();
        var preLaunchingObject = $("#object").val();

        swal({
            title: "해당 프리런칭을 삭제하시겠습니까?",
            type: "info",
            showCancelButton: true,
            closeOnConfirm: false,
            confirmButtonText: "확인",
            confirmButtonColor: "#21a9e1",
            cancelButtonText: "닫기",
        }, function () {
            if(preLaunchingSeq) {
                $.ajax({
                    url: "/event/deletePreLaunchingList",
                    type: "POST",
                    data: {
                        preLaunchingSeq: preLaunchingSeq,
                        preLaunchingObject: preLaunchingObject
                    },
                    async: false,
                    dataType: 'json',
                    success: function(rtn) {
                        if(rtn != -1) {
                            swal({
                                    title: "SUCCESS",
                                    text: "프리런칭 정보를 삭제하였습니다.",
                                    type: "success"
                                },
                                function () {
                                    dataTable.ajax.reload(null, false);
                                    $('#showPreLaunchingEvent').modal('hide');
                                });
                        } else {
                            swal("WARNING", "프리런칭 삭제를 실패하였습니다.", "warning");
                        }
                    }
                });
            }
        });
    }

    function addRowCategory() {
        var html = "";

        html += "<div class='row rowlist' type='addList_category' name='addList_category' style='margin-top: 15px;'>";
        html +=     "<div class='col-md-12'>"
        html +=         "<div class='form-group' style='display: flex;'>";
        html +=             "<select class='select2' name='edit_category' style='width: 23%'>";
        html +=                 "<option value=''>카테고리 선택</option>";
        html +=                 "<option value='G'>지티기어</option>";
        html +=             "</select>";
        html +=             "<select class='select2' name='edit_brand' style='width: 23%; margin-left: 15px;'>";
        html +=                 "<option value=''>브랜드 선택</option>"
        html +=             "</select>";
        html +=             "<select class='select2' name='edit_goods' style='width: 23%; margin-left: 15px;'>";
        html +=                 "<option value=''>상품 선택</option>"
        html +=             "</select>";
        html +=             "<select class='select2' name='edit_option' style='width: 24%; margin-left: 15px;'>";
        html +=                 "<option value=''>옵션 선택</option>"
        html +=             "</select>";
        html +=             "<button type='button' onclick='removeRow(this)' style='width:30px; height: 30px; float:left; margin-left: 15px;'>-</button>";
        html +=         "</div>";
        html +=     "</div>";
        html += "</div>";

        $('#addRowCategory').append(html);

        $('[name=edit_category]').last().select2();
        $("[name=edit_category]").on('change', function() {
            var categoryCode = $(this).find("option:selected").val();

            var html = "<option value=''>브랜드 선택</option>";
            if (categoryCode) {
                var brandList = getBrandList(categoryCode);
                $.each(brandList, function (brandIdx, brandValue) {
                    html += "<option value='" + brandValue.brand_code + "'>" + brandValue.brand_name + "</option>";
                });
            }
            $(this).parent().find('[name=edit_brand]').empty().append(html);
            $(this).parent().find('[name=edit_brand]').val('').trigger('change');
        });

        $('[name=edit_brand]').last().select2();
        $("[name=edit_brand]").on('change', function() {
            var categoryCode = $(this).parent().find("[name=edit_category] option:selected").val();
            var brandCode = $(this).find("option:selected").val();

            var html = "<option value=''>상품 선택</option>";
            if (categoryCode && brandCode) {
                var goodsList = getGoodsList(categoryCode, brandCode);
                $.each(goodsList, function (goodsIdx, goodsValue) {
                    html += "<option value='" + goodsValue.goods_code + "'>" + goodsValue.goods_name + "</option>";
                });
            }
            $(this).parent().find('[name=edit_goods]').empty().append(html);
            $(this).parent().find('[name=edit_goods]').val('').trigger('change');
        });

        $('[name=edit_goods]').last().select2();
        $("[name=edit_goods]").on('change', function() {
            var categoryCode = $(this).parent().find("[name=edit_category] option:selected").val();
            var brandCode = $(this).parent().find("[name=edit_brand] option:selected").val();
            var goodsCode = $(this).find("option:selected").val();

            var html = "<option value=''>옵션 선택</option>";
            if (categoryCode && brandCode && goodsCode) {
                var optionList = getOptionList(categoryCode, brandCode, goodsCode);

                var editOption = $(this).parent().find('[name=edit_option]');
                editOption.prop('disabled', true);
                $.each(optionList, function (optionIdx, optionValue) {
                    editOption.prop('disabled', false);
                    html += "<option value='" + optionValue.option_code + "'>" + optionValue.option_name + "</option>";
                });
            }
            $(this).parent().find('[name=edit_option]').empty().append(html);
            $(this).parent().find('[name=edit_option]').val('').trigger('change');
        });

        $('[name=edit_option]').last().select2();
    }

    function addRowGift() {
        var html = "";

        html += "<div class='row rowlist' type='addList_gift_category' name='addList_gift_category' style='margin-top: 15px;'>";
        html +=     "<div class='col-md-12'>"
        html +=         "<div class='form-group' style='display: flex;'>";
        html +=             "<select class='select2' name='edit_gift_category' style='width: 23%'>";
        html +=                 "<option value=''>카테고리 선택</option>";
        <c:forEach var='category' items='${categoryList}' varStatus='status'>
        html += "                <option value='${category.category_code}'>${category.category_name}</option>";
        </c:forEach>
        // html +=                 "<option value='G'>지티기어</option>";
        // html +=                 "<option value='K'>카팔아피</option>";
        html +=             "</select>";
        html +=             "<select class='select2' name='edit_gift_brand' style='width: 23%; margin-left: 15px;'>";
        html +=                 "<option value=''>브랜드 선택</option>"
        html +=             "</select>";
        html +=             "<select class='select2' name='edit_gift_goods' style='width: 23%; margin-left: 15px;'>";
        html +=                 "<option value=''>상품 선택</option>"
        html +=             "</select>";
        html +=             "<select class='select2' name='edit_gift_option' style='width: 24%; margin-left: 15px;'>";
        html +=                 "<option value=''>옵션 선택</option>"
        html +=             "</select>";
        html +=             "<button type='button' onclick='removeRow(this)' style='width:30px; height: 30px; float:left; margin-left: 15px;'>-</button>";
        html +=         "</div>";
        html +=     "</div>";
        html += "</div>";

        $('#addRowGift').append(html);

        $('[name=edit_gift_category]').last().select2();
        $("[name=edit_gift_category]").on('change', function() {
            var categoryCode = $(this).find("option:selected").val();

            var html = "<option value=''>브랜드 선택</option>";
            if (categoryCode) {
                var brandList = getBrandList(categoryCode);
                $.each(brandList, function (brandIdx, brandValue) {
                    html += "<option value='" + brandValue.brand_code + "'>" + brandValue.brand_name + "</option>";
                });
            }
            $(this).parent().find('[name=edit_gift_brand]').empty().append(html);
            $(this).parent().find('[name=edit_gift_brand]').val('').trigger('change');
        });

        $('[name=edit_gift_brand]').last().select2();
        $("[name=edit_gift_brand]").on('change', function() {
            var categoryCode = $(this).parent().find("[name=edit_gift_category] option:selected").val();
            var brandCode = $(this).find("option:selected").val();

            var html = "<option value=''>상품 선택</option>";
            if (categoryCode && brandCode) {
                var goodsList = getGoodsList(categoryCode, brandCode);
                $.each(goodsList, function (goodsIdx, goodsValue) {
                    html += "<option value='" + goodsValue.goods_code + "'>" + goodsValue.goods_name + "</option>";
                });
            }
            $(this).parent().find('[name=edit_gift_goods]').empty().append(html);
            $(this).parent().find('[name=edit_gift_goods]').val('').trigger('change');
        });

        $('[name=edit_gift_goods]').last().select2();
        $("[name=edit_gift_goods]").on('change', function() {
            var categoryCode = $(this).parent().find("[name=edit_gift_category] option:selected").val();
            var brandCode = $(this).parent().find("[name=edit_gift_brand] option:selected").val();
            var goodsCode = $(this).find("option:selected").val();

            var html = "<option value=''>옵션 선택</option>";
            if (categoryCode && brandCode && goodsCode) {
                var optionList = getOptionList(categoryCode, brandCode, goodsCode);

                var editGiftOption = $(this).parent().find('[name=edit_gift_option]');
                editGiftOption.prop("disabled", true);
                $.each(optionList, function (optionIdx, optionValue) {
                    editGiftOption.prop("disabled", false);
                    html += "<option value='" + optionValue.option_code + "'>" + optionValue.option_name + "</option>";
                });
            }
            $(this).parent().find('[name=edit_gift_option]').empty().append(html);
            $(this).parent().find('[name=edit_gift_option]').val('').trigger('change');
        });

        $('[name=edit_gift_option]').last().select2();
    }

    function addRowOption() {
        var html = "";

        html += "<div class='row rowlist' type='addList_option_category' name='addList_option_category'>";
        html +=     "<div>";
        html +=     "<div>";
        html +=         "<div class='form-group' style='width: 43%; float: left; margin-left: 15px;'>";
        html +=             "<label class='control-label'>옵션1</label>";
        html +=             "<input class='form-control' name='option1' id='option1'>"
        html +=         "</div>";
        html +=         "<div class='form-group' style='width: 43%; float: left; margin-left: 15px;'>";
        html +=             "<label class='control-label'>옵션2</label>";
        html +=             "<input class='form-control' name='option2' id='option2'>"
        html +=         "</div>";
        html +=         "<button type='button' onclick='removeRow(this)' style='width:30px; height: 30px; float:left; margin-left: 15px; margin-top: 22px;'>-</button>";
        html +=     "</div>";
        html +=     "</div>";
        html += "</div>";

        $('#addRowOption').append(html);

    }

    function addRowSubscribe() {
        var html = "";

        html += "<div class='row rowlist' type='addList_subscribe_category' name='addList_subscribe_category'>";
        html +=     "<div>";
        html +=     "<div>";
        html +=         "<div class='form-group' style='width: 86.5%; float: left; margin-left: 15px;'>";
        html +=             "<label class='control-label'>이미지 URL</label>";
        html +=             "<input class='form-control' name='imageUrl' id='imageUrl'>"
        html +=         "</div>";
        html +=         "<button type='button' onclick='removeRow(this)' style='width:30px; height: 30px; float:left; margin-left: 15px; margin-top: 22px;'>-</button>";
        html +=     "</div>";
        html +=     "</div>";
        html += "</div>";

        $('#addRowSubscribe').append(html);

    }

    function removeRow(row) {
        $(row).parent().parent().parent().remove();
    }

    $(document).ready(function () {
        $('#start_date_picker').datetimepicker({
            format: "YYYY-MM-DD"
        }).data('DateTimePicker').date(new Date());

        $('#end_date_picker').datetimepicker({
            format: "YYYY-MM-DD"
        }).data('DateTimePicker').date();

        $('#buy_start_date_picker').datetimepicker({
            format: "YYYY-MM-DD"
        }).data('DateTimePicker').date(new Date());

        $('#buy_end_date_picker').datetimepicker({
            format: "YYYY-MM-DD"
        }).data('DateTimePicker').date();


        $('[name=edit_category]').last().select2();
        $("[name=edit_category]").on('change', function() {
            var categoryCode = $("[name=edit_category] option:selected").val();

            var html = "<option value=''>브랜드 선택</option>";
            if (categoryCode) {
                var brandList = getBrandList(categoryCode);
                $.each(brandList, function (brandIdx, brandValue) {
                    html += "<option value='" + brandValue.brand_code + "'>" + brandValue.brand_name + "</option>";
                });
            }
            $('[name=edit_brand]').empty().append(html);
            $('[name=edit_brand]').val('').trigger('change');
        });

        $('[name=edit_brand]').last().select2();
        $("[name=edit_brand]").on('change', function() {
            var categoryCode = $("[name=edit_category] option:selected").val();
            var brandCode = $("[name=edit_brand] option:selected").val();

            var html = "<option value=''>상품 선택</option>";
            if (categoryCode && brandCode) {
                var goodsList = getGoodsList(categoryCode, brandCode);
                $.each(goodsList, function (goodsIdx, goodsValue) {
                    html += "<option value='" + goodsValue.goods_code + "'>" + goodsValue.goods_name + "</option>";
                });
            }
            $('[name=edit_goods]').empty().append(html);
            $('[name=edit_goods]').val('').trigger('change');
        });

        $('[name=edit_goods]').last().select2();
    });


    $(window).on("load", function () {
        setData();
    });

</script>

<style>
    .select2-drop {z-index: 999999;}
</style>

<body class="page-body" data-url="http://neon.dev" onload="onLoad()">
<div class="page-container horizontal-menu">

    <jsp:include page="../header_vertical.jsp" flush="false"/>

    <div class="main-content">

        <jsp:include page="../header_horizontal.jsp" flush="false"/>

        <div class="row" style="margin-top: 10px;">
            <div class="col-md-12">
                <h2 style="display: inline-block;">프리런칭 관리</h2>

                <button type="button" style="color: #000000; font-size: 15px;
                        height: 40px; margin-left: 15px;
                        margin-top: 10px; vertical-align: super;" onclick="showPreLaunchingEvent()">+ 프리런칭 등록</button>

                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-primary">
                            <table class="table table-bordered hover" id="result"></table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="showPreLaunchingEvent" style="z-index: 10001; overflow-x: hidden; overflow-y: auto; margin-top: 30px;">
    <div content="modal-dialog" style="width: 35%; margin: auto;">
        <div class="modal-content">

            <input type="hidden" id="preLaunching_seq">

            <div class="modal-header">
                <button type="button" class="close display" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title" style="font-size: 18px;">프리런칭 등록</h4>
            </div>

            <div class="modal-body">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="control-label">프리런칭 제목</label>
                            <input class="form-control" id="preLaunchingTitle">
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="control-label">고유 URL (생성 후 변경불가)</label>
                            <input class="form-control" id="object">
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="control-label">시작일자</label>
                            <div class="input-group date-and-time" id="start_date_picker">
                                <input type="text" class="form-control" id="startDate">
                                <span class="input-group-addon">
                                            <span class="glyphicon glyphicon-calendar"></span>
                                        </span>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="control-label">종료일자</label>
                            <div class="input-group date-and-time" id="end_date_picker">
                                <input type="text" class="form-control" id="endDate">
                                <span class="input-group-addon">
                                            <span class="glyphicon glyphicon-calendar"></span>
                                        </span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="control-label">예약구매 시작일자</label>
                            <div class="input-group date-and-time" id="buy_start_date_picker">
                                <input type="text" class="form-control" id="buyStartDate">
                                <span class="input-group-addon">
                                            <span class="glyphicon glyphicon-calendar"></span>
                                        </span>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="control-label">예약구매 종료일자</label>
                            <div class="input-group date-and-time" id="buy_end_date_picker">
                                <input type="text" class="form-control" id="buyEndDate">
                                <span class="input-group-addon">
                                            <span class="glyphicon glyphicon-calendar"></span>
                                        </span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-4">
                        <div class="form-group" >
                            <label class="control-label">프리런칭 카테고리 선택</label>
                            <select class="select2" name="edit_category">
                                <option value=''>카테고리 선택</option>
                                <c:forEach var='categoryList' items='${categoryList}' varStatus='status'>
                                    <option value='${categoryList.category_code}'>${categoryList.category_name}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="form-group">
                            <label class="control-label">프리런칭 브랜드 선택</label>
                            <select class='select2' name='edit_brand'>
                                <option value=''>브랜드 선택</option>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="form-group">
                            <label class="control-label">프리런칭 제품 선택</label>
                            <select class='select2' name='edit_goods'>
                                <option value=''>상품 선택</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="row" style="margin-top: 15px;">
                    <div class="col-md-12">
                        <div class="form-group" >
                            <label class="control-label">옵션 입력</label>
                            <button type="button" class="control-buttons-tab" onclick="addRowOption()" style='padding: 0px 12px; height: 30px; color: #333; margin-right: 15px;
                            font-size: 14px; font-weight: 500; width: 50px; float: right;'>+</button>
                            <div class="form-group" id="addRowOption" style="margin-top: 10px;">

                            </div>
                        </div>
                    </div>
                </div>

                <div class="row" style="margin-top: 15px;">
                    <div class="col-md-12">
                        <div class="form-group" >
                            <label class="control-label">구독자 페이지 이미지</label>
                            <button type="button" class="control-buttons-tab" onclick="addRowSubscribe()" style='padding: 0px 12px; height: 30px; color: #333; margin-right: 15px;
                            font-size: 14px; font-weight: 500; width: 50px; float: right;'>+</button>
                            <div class="form-group" id="addRowSubscribe" style="margin-top: 10px;">

                            </div>
                        </div>
                    </div>
                </div>

                <div class="row" style="padding-top: 15px; background-color: #b2b2b2">
                    <div class="col-md-12">
                        <div class="form-group">
                            <label class="control-label">사은품 선택 <strong style="color: red; font-weight: bold;"> * 주의!! 아래 선택된 사은품은 자동 발송 처리 됩니다. </strong></label>
                            <button type="button" class="control-buttons-tab" onclick="addRowGift()" style='padding: 0px 12px; height: 30px; color: #333; margin-right: 15px;
                            font-size: 14px; font-weight: 500; width: 50px; float: right;'>+</button>
                            <div class="form-group" id="addRowGift">

                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-red" id="deletePreLaunchingEvent" style="float:left;" onclick="deletePreLaunchingEvent()">삭제</button>
                <button type="button" class="btn btn-info" onclick="savePreLaunchingEvent()">저장</button>
                <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>
</body>
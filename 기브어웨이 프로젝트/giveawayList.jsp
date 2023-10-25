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

<script>
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
            order: [0, "desc"],
            // Buttons
            buttons: ['copyHtml5', 'excelHtml5', 'csvHtml5'],
            ajax: {
                url: "/event/selectGiveawayEventList_DT",
                type: 'GET',
                dataType: 'json',
            },
            columns: [
                {
                    className: "center",
                    data: "giveawaySeq",
                    title: '번호',
                    width: "5%"
                },
                {
                    className: "center",
                    data: "giveawayType",
                    render: function (data, type, row, meta) {
                        var rtn = "";
                        if(data == "keychron") {
                            rtn = "키크론"
                        } else {
                            rtn = "지티기어"
                        }
                        return rtn;
                    },
                    title: '채널',
                    width: "8%"
                },
                {
                    className: "center",
                    data: "giveawayTitle",
                    render: function (data, type, row, meta) {
                        var rtn = "<a href='javascript:;'";
                        rtn += " onclick='showGiveawayEvent(\"" + row.giveawaySeq + "\")'";
                        rtn += " style='font-weight: bold;'>";
                        rtn += data;
                        rtn += "</a>";

                        return rtn;
                    },
                    title: '제목',
                },
                {
                    className: "center",
                    data: "startDate",
                    title: '시작일',
                    width: "12%"
                },
                {
                    className: "center",
                    data: "endDate",
                    title: '종료일',
                    width: "12%"
                },
                {
                    className: "center",
                    data: "rewardDate",
                    title: '발표일',
                    width: "12%"
                },
                {
                    className: "center",
                    render: function (data, type, row, meta) {
                        var startDate = new Date(row.startDate);
                        var endDate = new Date(row.endDate);
                        var now = new Date();

                        var rtn = "";
                        rtn = "<div style='font-weight: bolder;"
                        if(now < startDate) {
                            rtn += " color: Blue;'>예정</div>"
                        } else if (endDate < now) {
                            rtn += " color: Black;'>종료</div>"
                        } else {
                            rtn += " color: Red;'>진행 중</div>"
                        }

                        return rtn;
                    },
                    title: '상태',
                    width: "8%"
                },
                {
                    className: "center",
                    render: function (data, type, row, meta) {
                        var rtn = "";

                        rtn += '<button type="button" onclick="window.open(\'/event/giveawayResult?object=';
                        rtn += row.object;
                        rtn += '\')" style="padding: 5px; color: #0b0d0f">';
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

    function showGiveawayEvent(giveawaySeq) {
        $("#giveawayType").val("");
        $("#giveawayTitle").val("");
        $("#giveaway_seq").val("");
        $("#object").val("");
        $("#startDate").val("");
        $("#endDate").val("");
        $("#rewardDate").val("");
        $("#giveawayText").val("");
        $("#successText").val("");
        $("#button_text").val("")
        $("#button_link").val("")
       $("#YN").val("N")
        $("#check_YN").prop("checked",false);
        $(".rowlist").remove();
        $("#homeSub").val("");
        $("#homeMain").val("");
        $("#homeLink").val("");
        $("#winnerTitle").val("");
        $("#winnerText").val("");
        $("#winnerLink").val("");
        $("#coupon_title").val("");
        $("#coupon_link").val("");
        $("#rewardTitle").val("");
        $("#rewardImageLink").val("");
        $("#rewardImageLink2").val("");
        $("#rewardLink").val("");
        $("#rewardText").val("");
        $("#winnerNum").val("");

        $("#deleteGiveawayEvent").hide();

        if(giveawaySeq) {
            $("#giveaway_seq").val(giveawaySeq)
            $("#deleteGiveawayEvent").show();

            $.ajax({
                url: "/event/selectGiveawayEventDetail",
                type: 'POST',
                data: {
                    giveawaySeq: giveawaySeq
                },
                async: false,
                dataType: 'json',
                success: function (detailInfo) {
                    $("#giveawayType").val(detailInfo.giveawayType);
                    $("#giveaway_seq").val(giveawaySeq);
                    $("#object").val((detailInfo.object).replace(/[^0-9]/g,''));
                    $("#giveawayTitle").val(detailInfo.giveawayTitle);
                    $("#startDate").val(detailInfo.startDate);
                    $("#endDate").val(detailInfo.endDate);
                    $("#rewardDate").val(detailInfo.rewardDate);
                    $("#giveawayText").val((detailInfo.giveawayText).replaceAll("<br>","\n"));
                    $("#successText").val((detailInfo.successText).replaceAll("<br>","\n"));
                    $("#button_text").val(detailInfo.buttonText);
                    $("#button_link").val(detailInfo.buttonLink);
                    if(detailInfo.buttonFlag == "N") {
                        $("#YN").val("N")
                        $("#check_YN").prop("checked",false);
                    } else {
                        $("#YN").val("Y")
                        $("#check_YN").prop("checked",true);
                    }

                    $("#homeSub").val(detailInfo.homeSub);
                    $("#homeMain").val(detailInfo.homeMain);
                    $("#homeLink").val(detailInfo.homeLink);
                    $("#winnerTitle").val((detailInfo.winnerTitle).replaceAll("<br>","\n"));
                    $("#winnerText").val((detailInfo.winnerText).replaceAll("<br>","\n"));
                    $("#winnerLink").val((detailInfo.winnerLink).replaceAll("<br>","\n"));
                    $("#coupon_title").val(detailInfo.couponTitle);
                    $("#coupon_link").val(detailInfo.couponLink);
                    $("#rewardTitle").val(detailInfo.rewardTitle);
                    $("#rewardImageLink").val(detailInfo.rewardImageLink);
                    $("#rewardImageLink2").val(detailInfo.rewardImageLink2);
                    $("#rewardLink").val(detailInfo.rewardLink);
                    $("#rewardText").val((detailInfo.rewardText).replaceAll("<br>","\n"));
                    $("#winnerNum").val(detailInfo.winnerNum);

                    messageObject = detailInfo.object;

                    var winnerText = "";
                    if(detailInfo.winnerText) {
                        winnerText = detailInfo.winnerText.replaceAll("<br>","\n")
                        winnerText = winnerText.split("\n");

                        for (var i = 0; i < winnerText.length; i += 2) {
                            var html = "";
                            html += "<div class='row rowlist' type='addList_item_winner' name='mission' style='margin-top: 15px;'>";
                            html +=     "<div class='form-group'>";
                            html +=         "<input type='text' class='form-control' name='winnerPhone' id='winnerPhone' value='" + winnerText[i]  +"' style='float:left; width: 44%; margin-left: 15px;' placeholder='연락처'>";
                            html +=         "<input type='text' class='form-control' name='winnerEmail' id='winnerEmail' value='" + winnerText[i+1] + "' style='float:left; width: 44%; margin-left: 15px;' placeholder='이메일'>";
                            html +=         "<button type='button' onclick='removeRow(this)' style='width:30px; height: 30px; float:left; margin-left: 15px;'>-</button>";
                            html +=     "</div>";
                            html += "</div>";

                            $('div#addWinnerRow').append(html);
                        }
                    }

                    $.ajax({
                        url: "/event/selectGiveawayEventItemDetail",
                        type: 'GET',
                        data: {
                            giveawaySeq: giveawaySeq
                        },
                        async: false,
                        dataType: 'json',
                        success: function (detailItem) {
                            for(var i = 0; i < detailItem.length; i++) {
                                if(detailItem[i].type == "image") {
                                    var html = "";
                                    html += "<div class='row rowlist' type='addList_item_image' style='margin-top: 15px;'>";
                                    html +=     "<div class='form-group'>";
                                    html +=         "<input type='text' class='form-control' name='imageLink' id='imageLink' style='float:left; width: 90%; margin-left: 15px;' value='"+ detailItem[i].link +"'>";
                                    html +=         "<button type='button' onclick='removeRow(this)' style='width:30px; height: 30px; float:left; margin-left: 15px;'>-</button>";
                                    html +=     "</div>";
                                    html += "</div>";

                                    $('div#addImageRow').append(html);
                                } else if (detailItem[i].type == "mission") {
                                    var html = "";
                                    html += "<div class='row rowlist' type='addList_item_mission' name='mission' style='margin-top: 15px;'>";
                                    html +=     "<div class='form-group'>";
                                    html +=         "<input type='text' class='form-control' name='iconLink' id='iconLink' style='float:left; width: 40%; margin-left: 15px;' placeholder='아이콘 링크' value='" + detailItem[i].missionIcon + "'>";
                                    html +=         "<input type='text' class='form-control' name='missionText' id='missionText' style='float:left; width: 25%; margin-left: 15px;' placeholder='미션 내용' value='" + detailItem[i].missionTitle  + "'>";
                                    html +=         "<input type='text' class='form-control' name='missionLink' id='missionLink' style='float:left; width: 21%; margin-left: 15px;' placeholder='미션 링크' value='" + detailItem[i].link + "'>";
                                    html +=         "<button type='button' onclick='removeRow(this)' style='width:30px; height: 30px; float:left; margin-left: 15px;'>-</button>";
                                    html +=     "</div>";
                                    html += "</div>";

                                    $('div#addMissionRow').append(html);
                                }
                            }
                        },
                        error: function (jqXHR, textStatus, errorThrown) {
                            swal("ajax error", "giveawayList.jsp - selectAddListItemDetail()", "error");
                            console.log(jqXHR.responseText);
                            console.log(textStatus);
                            console.log(errorThrown);
                        }
                    });
                }
            });
        }

        $('#showGiveawayEvent').modal({backdrop: 'static', keyboard: false});
    }

    function addImageRow() {
        var html = "";
        html += "<div class='row rowlist' type='addList_item_image' style='margin-top: 15px;'>";
        html +=     "<div class='form-group'>";
        html +=         "<input type='text' class='form-control' name='imageLink' id='imageLink' style='float:left; width: 90%; margin-left: 15px;'>";
        html +=         "<button type='button' onclick='removeRow(this)' style='width:30px; height: 30px; float:left; margin-left: 15px;'>-</button>";
        html +=     "</div>";
        html += "</div>";

        $('div#addImageRow').append(html);
    }

    function addMissionRow() {
        var html = "";
        html += "<div class='row rowlist' type='addList_item_mission' name='mission' style='margin-top: 15px;'>";
        html +=     "<div class='form-group'>";
        html +=         "<input type='text' class='form-control' name='iconLink' id='iconLink' style='float:left; width: 40%; margin-left: 15px;' placeholder='아이콘 링크'>";
        html +=         "<input type='text' class='form-control' name='missionText' id='missionText' style='float:left; width: 25%; margin-left: 15px;' placeholder='미션 내용'>";
        html +=         "<input type='text' class='form-control' name='missionLink' id='missionLink' style='float:left; width: 21%; margin-left: 15px;' placeholder='미션 링크 URL'>";
        html +=         "<button type='button' onclick='removeRow(this)' style='width:30px; height: 30px; float:left; margin-left: 15px;'>-</button>";
        html +=     "</div>";
        html += "</div>";

        $('div#addMissionRow').append(html);
    }

    function addWinnerRow() {
        var html = "";
        html += "<div class='row rowlist' type='addList_item_winner' name='mission' style='margin-top: 15px;'>";
        html +=     "<div class='form-group'>";
        html +=         "<input type='text' class='form-control' name='winnerPhone' id='winnerPhone' style='float:left; width: 44%; margin-left: 15px;' placeholder='연락처'>";
        html +=         "<input type='text' class='form-control' name='winnerEmail' id='winnerEmail' style='float:left; width: 44%; margin-left: 15px;' placeholder='이메일'>";
        html +=         "<button type='button' onclick='removeRow(this)' style='width:30px; height: 30px; float:left; margin-left: 15px;'>-</button>";
        html +=     "</div>";
        html += "</div>";

        $('div#addWinnerRow').append(html);
    }

    function removeRow(row) {
        $(row).parent().parent().remove();
    }

    function saveGiveawayEvent() {
        var mainImage = $('div[type=addList_item_image]').find('input').eq(0).val();

        var giveawayType = $("#giveawayType").val();
        var giveawaySeq = $("#giveaway_seq").val();
        var object = $("#object").val();
        var giveawayTitle = $("#giveawayTitle").val();
        var startDate = $("#startDate").val();
        var endDate = $("#endDate").val();
        var rewardDate = $("#rewardDate").val();
        var giveawayText = "";
        var successText = $("#successText").val().replaceAll(/(?:\r\n|\r|\n)/g,"<br>");
        var buttonText = "";
        var buttonLink = "";
        var buttonFlag = $("#YN").val();
        var homeSub = "";
        var homeMain = giveawayTitle;
        var homeLink = mainImage;
        var winnerTitle = giveawayTitle;
        var winnerText = "";
        $('div[type=addList_item_winner]').each(function () {
            var winnerPhone = $(this).find('input[name=winnerPhone]').val();
            var winnerEmail = $(this).find('input[name=winnerEmail]').val();

            winnerText += winnerPhone + "<br>" + winnerEmail  + "<br>" ;
        });
        winnerText = winnerText.slice(0,-4);
        var winnerLink = ""
        var couponTitle = "";
        var couponLink = "";
        var rewardTitle = giveawayTitle;
        var rewardImageLink = mainImage;
        var rewardImageLink2 = mainImage;
        var rewardLink = $("#rewardLink").val();
        var rewardText = $("#rewardText").val().replaceAll(/(?:\r\n|\r|\n)/g,"<br>");
        var winnerNum = $("#winnerNum").val();

        if (object == "") {
            swal("WARNING", "기브어웨이 회차를 입력해 주세요 !", "warning");
        } else if (giveawayTitle == "") {
            swal("WARNING", "기브어웨이 제목을 입력해 주세요 !", "warning");
        } else if (startDate == "") {
            swal("WARNING", "시작일시를 선택해 주세요 !", "warning");
        } else if (endDate == "") {
            swal("WARNING", "종료일시를 입력해 주세요 !", "warning");
        } else if (rewardDate == "") {
            swal("WARNING", "당첨자발표일시를 입력해 주세요 !", "warning");
        }  else if (successText == "") {
            swal("WARNING", "성공 후 멘트를 입력해 주세요 !", "warning");
        }  else if (homeMain == "") {
            swal("WARNING", "공홈 메인 텍스트를 입력해 주세요 !", "warning");
        } else if (homeLink == "") {
            swal("WARNING", "공홈 이벤트 이미지 링크를 입력해 주세요 !", "warning");
        } else if (giveawayType == "") {
            swal("WARNING", "기브어웨이 채널을 선택해 주세요 !", "warning");
        } else if (winnerNum == "") {
            swal("WARNING", "당첨자 수를 입력해 주세요 !", "warning");
        }  else if (rewardImageLink == "") {
            swal("WARNING", "리워드 상세정보 이미지를(첫페이지) 선택해 주세요 !", "warning");
        } else if (rewardImageLink2 == "") {
            swal("WARNING", "리워드 상세정보 이미지(마지막페이지)를 선택해 주세요 !", "warning");
        } else if (rewardLink == "") {
            swal("WARNING", "리워드 상세정보 URL을 입력해 주세요 !", "warning");
        } else if (rewardText == "") {
            swal("WARNING", "리워드 상세정보 내용을 선택해 주세요 !", "warning");
        } else {
            if(giveawayType == "keychron") {
                var object = "keychron_giveaway" + $("#object").val();
            } else {
                var object = "gtgear_giveaway" + $("#object").val();
            }

            if(giveawaySeq == "") {

                swal({
                    title: "기브어웨이 이벤트를 저장하시겠습니까?",
                    type: "info",
                    showCancelButton: true,
                    closeOnConfirm: false,
                    confirmButtonText: "확인",
                    confirmButtonColor: "#21a9e1",
                    cancelButtonText: "닫기",
                }, function () {
                    $.ajax({
                        url: '/event/insertGiveawayEvent',
                        type: 'POST',
                        data: {
                            giveawayType: giveawayType,
                            object: object,
                            giveawayTitle: giveawayTitle,
                            startDate: startDate,
                            endDate: endDate,
                            rewardDate: rewardDate,
                            giveawayText: "",
                            successText: successText,
                            buttonText: buttonText,
                            buttonLink: buttonLink,
                            buttonFlag: buttonFlag,
                            homeSub: "",
                            homeMain: homeMain,
                            homeLink: homeLink,
                            winnerTitle: winnerTitle,
                            winnerText: winnerText,
                            winnerLink: "",
                            couponTitle: couponTitle,
                            couponLink: couponLink,
                            rewardTitle: rewardTitle,
                            rewardImageLink: rewardImageLink,
                            rewardImageLink2: rewardImageLink2,
                            rewardLink: rewardLink,
                            rewardText: rewardText,
                            winnerNum: winnerNum
                        },
                        async: false,
                        success: function (rtn) {
                            var c=0;
                            if(rtn != -1) {
                                $('div[type=addList_item_image]').each(function () {
                                    var imageLink = $(this).find('input[name=imageLink]').val();
                                    var type = "image"
                                    giveawaySeq = rtn;

                                    $.ajax({
                                        url: '/event/insertGiveawayEventImage',
                                        type: 'GET',
                                        data: {
                                            giveawaySeq: giveawaySeq,
                                            imageLink: imageLink,
                                            type: type
                                        },
                                        async: false,
                                        success: function (rtn2) {
                                            if (rtn2 != 1) {
                                                c = 1;
                                            }
                                        }
                                    });
                                });

                                $('div[type=addList_item_mission]').each(function () {
                                    var iconLink = $(this).find('input[name=iconLink]').val();
                                    var missionText = $(this).find('input[name=missionText]').val();
                                    var missionLink = $(this).find('input[name=missionLink]').val();
                                    var type = "mission";

                                    $.ajax({
                                        url: "/event/insertGiveawayEventMission",
                                        type: 'GET',
                                        data: {
                                            giveawaySeq: giveawaySeq,
                                            iconLink: iconLink,
                                            missionText: missionText,
                                            missionLink: missionLink,
                                            type: type
                                        },
                                        async: false,
                                        success: function (rtn3) {
                                            if(rtn3 != 1) {
                                                c = 2;
                                            }
                                        }
                                    });
                                });

                                if(c == 0) {
                                    swal({
                                        title: "SUCCESS",
                                        text: "기브어웨이 이벤트를 추가하였습니다.",
                                        type: "success"
                                    },
                                    function () {
                                        dataTable.ajax.reload(null, false);
                                        $('#showGiveawayEvent').modal('hide');
                                    });
                                } else {
                                    swal("WARNING", "기브어웨이 이벤트 저장을 실패하였습니다.", "warning");
                                }

                            } else {
                                swal("WARNING", "기브어웨이 이벤트 저장을 실패하였습니다.", "warning");
                            }
                        }

                    });
                });

            } else {
                swal({
                    title: "해당 기브어웨이 이벤트를 수정하시겠습니까?",
                    type: "info",
                    showCancelButton: true,
                    closeOnConfirm: false,
                    confirmButtonText: "확인",
                    confirmButtonColor: "#21a9e1",
                    cancelButtonText: "닫기",
                }, function () {
                    $.ajax({
                        url: "/event/updateGiveawayEvent",
                        type: "GET",
                        data: {
                            giveawayType: giveawayType,
                            object: object,
                            giveawayTitle: giveawayTitle,
                            startDate: startDate,
                            endDate: endDate,
                            rewardDate: rewardDate,
                            giveawayText: "",
                            successText: successText,
                            giveawaySeq: giveawaySeq,
                            buttonText: buttonText,
                            buttonLink: buttonLink,
                            buttonFlag: buttonFlag,
                            homeSub: "",
                            homeMain: homeMain,
                            homeLink: homeLink,
                            winnerText: winnerText,
                            winnerTitle: winnerTitle,
                            winnerLink: "",
                            couponTitle: couponTitle,
                            couponLink: couponLink,
                            rewardTitle: rewardTitle,
                            rewardImageLink: rewardImageLink,
                            rewardImageLink2: rewardImageLink2,
                            rewardLink: rewardLink,
                            rewardText: rewardText,
                            winnerNum: winnerNum
                        },
                        async: false,
                        success: function (rtn) {
                            if(rtn != -1) {
                                var c = 0;
                                $('div[type=addList_item_image]').each(function () {
                                    var imageLink = $(this).find('input[name=imageLink]').val();
                                    var type = "image"

                                    $.ajax({
                                        url: '/event/insertGiveawayEventImage',
                                        type: 'GET',
                                        data: {
                                            giveawaySeq: giveawaySeq,
                                            imageLink: imageLink,
                                            type: type
                                        },
                                        async: false,
                                        success: function (rtn2) {
                                            if (rtn2 != 1) {
                                                c = 1;
                                            }
                                        }
                                    });
                                });

                                $('div[type=addList_item_mission]').each(function () {
                                    var iconLink = $(this).find('input[name=iconLink]').val();
                                    var missionText = $(this).find('input[name=missionText]').val();
                                    var missionLink = $(this).find('input[name=missionLink]').val();
                                    var type = "mission";

                                    $.ajax({
                                        url: "/event/insertGiveawayEventMission",
                                        type: 'GET',
                                        data: {
                                            giveawaySeq: giveawaySeq,
                                            iconLink: iconLink,
                                            missionText: missionText,
                                            missionLink: missionLink,
                                            type: type
                                        },
                                        async: false,
                                        success: function (rtn3) {
                                            if(rtn3 != 1) {
                                                c = 1;
                                            }
                                        }
                                    });
                                });

                                if(c == 0) {
                                    swal({
                                        title: "SUCCESS",
                                        text: "기브어웨이 이벤트를 수정하였습니다.",
                                        type: "success"
                                    },
                                    function () {
                                        $('#showGiveawayEvent').modal('hide');
                                        setData();
                                    });
                                } else {
                                    swal("WARNING", "기브어웨이 이벤트 수정을 실패하였습니다.", "warning");
                                }
                            } else {
                                swal("WARNING", "기브어웨이 이벤트 수정을 실패하였습니다.", "warning");
                            }
                        }
                    });
                });
            }
        }
    }

    function deleteGiveawayEvent() {
        var giveawaySeq = $("#giveaway_seq").val();
        swal({
                title: "해당 기브어웨이 이벤트를 삭제하시겠습니까?",
                type: "info",
                showCancelButton: true,
                closeOnConfirm: false,
                confirmButtonText: "확인",
                confirmButtonColor: "#21a9e1",
                cancelButtonText: "닫기",
            }, function () {
            $.ajax({
                url: "/event/deleteGiveawayEvent",
                type: 'GET',
                data: {
                    giveawaySeq: giveawaySeq,
                    messageObject: messageObject
                },
                async: false,
                success: function (rtn) {
                    if (rtn >= 1) {
                        swal({
                            title: "SUCCESS",
                            text: "기브어웨이 이벤트를 삭제하였습니다.",
                            type: "success"
                        },
                        function () {
                            dataTable.ajax.reload(null, false);
                            $('#showGiveawayEvent').modal('hide');
                        });
                    } else {
                        swal({
                            title: "WARNING",
                            text: "알 수 없는 오류가 발생하였습니다.",
                            type: "warning"
                        });
                    }
                }
            });
        });
    }


    $(document).ready(function () {
        $('#start_date_picker').datetimepicker({
            format: "YYYY-MM-DD HH:mm:ss"
        }).data('DateTimePicker').date(new Date());

        $('#end_date_picker').datetimepicker({
            format: "YYYY-MM-DD HH:mm:ss"
        }).data('DateTimePicker').date();

        $('#reward_date_picker').datetimepicker({
            format: "YYYY-MM-DD HH:mm:ss"
        }).data('DateTimePicker').date();

        $("#check_YN").change( function () {
            if($("#check_YN").is(":checked")) {
                $("#YN").val("Y");
            } else {
                $("#YN").val("N");
            }
        });
    });

    $(window).on("load", function () {
        setData();
    });
</script>

<style>
    .hr { border-top:2px solid #2F2F2F }
</style>

<body class="page-body" data-url="http://neon.dev" onload="onLoad()">

<div class="page-container horizontal-menu">

    <jsp:include page="../header_vertical.jsp" flush="false"/>

    <div class="main-content">

        <jsp:include page="../header_horizontal.jsp" flush="false"/>

        <div class="row" style="margin-top: 10px;">
            <div class="col-md-12">
                <h2 style="display: inline-block;">기브어웨이 관리</h2>

                <button type="button" style="color: #000000; font-size: 15px;
                        height: 40px; margin-left: 15px;
                        margin-top: 10px; vertical-align: super;" onclick="showGiveawayEvent()">+ 기브어웨이 등록</button>

                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-primary">
                            <table class="table table-bordered hover" id="result"></table>
                        </div>
                    </div>
                </div>

                <jsp:include page="../footer.jsp" flush="false"/>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="showGiveawayEvent" style="z-index: 10001; overflow-x: hidden; overflow-y: auto; margin-top: 30px;">
    <div content="modal-dialog" style="width: 85%; margin: auto;">
        <div class="modal-content">

            <input type="hidden" id="giveaway_seq">

            <div class="modal-header">
                <button type="button" class="close display" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title" style="font-size: 18px;">기브어웨이 등록</h4>
            </div>

            <div class="modal-body">
                <div class="row">
                    <div class="col-md-6">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="form-group">
                                    <label class="control-label">기브어웨이 제목</label>
                                    <input class="form-control" id="giveawayTitle">
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-12">
                                <div class="form-group">
                                    <label class="control-label">리워드 상세정보 URL</label>
                                    <input class="form-control" id="rewardLink">
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-12">
                                <div class="form-group">
                                    <label class="control-label">리워드 소개</label>
                                    <textarea class="form-control" id="rewardText" style="resize: vertical; height: 70px;"></textarea>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label class="control-label">기브어웨이 채널</label>
                                    <select id="giveawayType" class="form-control">
                                        <option value="">타입 선택</option>
                                        <option value="keychron">키크론</option>
                                        <option value="gtgear">지티기어</option>
                                    </select>
                                </div>
                            </div>

                            <div class="col-md-6">
                                <div class="form-group">
                                    <label class="control-label">기브어웨이 회차</label>
                                    <input type="text" class="form-control" id="object" placeholder="">
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label class="control-label">시작 일시</label>
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
                                    <label class="control-label">종료 일시</label>
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
                                    <label class="control-label">당첨자 발표 일시</label>
                                    <div class="input-group date-and-time" id="reward_date_picker">
                                        <input type="text" class="form-control" id="rewardDate">
                                        <span class="input-group-addon">
                                            <span class="glyphicon glyphicon-calendar"></span>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-3">
                                <div class="form-group">
                                    <label class="control-label">당첨자 수 (숫자만 입력)</label>
                                    <input class="form-control" type="number" id="winnerNum">
                                </div>
                            </div>

                            <div class="col-md-3">
                                <div class="form-group">
                                    <label class="control-label">쿠폰 유무</label><br>
                                    <input type="hidden" id="YN">
                                    <input type="checkbox" id="check_YN" style="transform: scale(2); margin-top: 8px;">
                                </div>
                            </div>
                        </div>

                    </div>

                    <div class="col-md-6">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="form-label">
                                    <label clss="control-label">이미지 추가(1번이 대표 썸네일이 됩니다.)</label>
                                    <button type="button" class="control-buttons-tab" onclick="addImageRow()" style='padding: 0px 12px; height: 30px; color: #333; margin-right: 15px;
                            font-size: 14px; font-weight: 500; width: 50px; float: right;'>+</button>
                                </div>
                                <div class="form-group" id="addImageRow">

                                </div>
                            </div>
                        </div>

                        <div class="row" style="margin-top: 15px;">
                            <div class="col-md-12">
                                <div class="form-group">
                                    <label clss="control-label">기브어웨이 미션</label>
                                    <button type="button" class="control-buttons-tab" onclick="addMissionRow()" style='padding: 0px 12px; height: 30px; color: #333; margin-right: 15px;
                            font-size: 14px; font-weight: 500; width: 50px; float: right;'>+</button>
                                </div>
                                <div class="form-group" id="addMissionRow">

                                </div>
                            </div>
                        </div>

                        <div class="row" style="margin-top: 15px;">
                            <div class="col-md-12">
                                <div class="form-group">
                                    <label class="control-label">당첨자 명단</label>
                                    <button type="button" class="control-buttons-tab" onclick="addWinnerRow()" style='padding: 0px 12px; height: 30px; color: #333; margin-right: 15px;
                            font-size: 14px; font-weight: 500; width: 50px; float: right;'>+</button>
                                </div>
                                <div class="form-group" id="addWinnerRow">

                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-12">
                                <div class="form-group">
                                    <label class="control-label">완료 멘트</label>
                                    <textarea class="form-control" id="successText" style="resize: vertical; height: 60px;"></textarea>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-red" onclick="deleteGiveawayEvent()" id="deleteGiveawayEvent" style="float:left;">삭제</button>
                <button type="button" class="btn btn-info" onclick="saveGiveawayEvent()">저장</button>
                <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>

</div>
</body>

<script>

    var missionCount = 0;
    var count = 0;
    var listChkNum = 0;
    var object = getParameterByName('object');
    var giveawaySeq = "";

    function openPage(rtn) {
        if(rtn == "mission") {
            jQuery("#copy_pop").removeClass("clear");
            jQuery.ajax({
                url: '/api/wpGiveawayDateCheck',
                type: 'post',
                data: {
                    object: object,
                },
                async: false,
                success: function (rtn) {

                    if(rtn == 1) {
                        jQuery("#giveaway_start").removeClass('block');
                        jQuery("#mission").addClass('block');
                    } else {
                        swal({
                            title: "참여가능 시간이 아닙니다.",
                            icon: "error"
                        });
                    }
                }
            });
        }

        if(rtn == "account") {
            jQuery("#mission").removeClass("block");
            jQuery("#account_default").addClass("block");

        }

        if(rtn == "eventApproval") {
            jQuery("#account_default").removeClass("block");
            jQuery("#account_info").addClass("block");
            jQuery("#eventApproval").addClass("block");
            jQuery("#personalInfo").removeClass("block");
        }

        if(rtn == "personalInfo") {
            jQuery("#account_default").removeClass("block");
            jQuery("#account_info").addClass("block");
            jQuery("#eventApproval").removeClass("block");
            jQuery("#personalInfo").addClass("block");
        }

        if(rtn == "finish") {
            jQuery(".right_button").removeAttr("onclick");
            var phone = jQuery('#phone_number').val();
            var email = jQuery('#email').val();

            if(jQuery("#allYes").hasClass("all_chk")) {
                jQuery("div.popup>div.popup_wrap2>div.button>a").removeAttr("onclick");
                jQuery.ajax({
                    url: '/api/wpGiveaway',
                    type: 'post',
                    data: {
                        title: object,
                        email: email,
                        phone: phone
                    },
                    async: false,
                    success: function(message) {
                        if (message == "fail") {
                            swal({
                                title: "WARNING",
                                text: "참여 이력이 존재합니다!",
                                type: "warning",
                            }).then( function () {
                                location.href = "https://keychron.kr/giveaway_home/";
                            });
                        } else if (message == "success") {
                            jQuery("#account_default").removeClass("block");
                            jQuery("#finish").addClass("block");
                        } else {
                            jQuery("#account_default").removeClass("block");
                            jQuery("#finish").addClass("block");
                        }
                    }
                });

            } else {
                swal("WARNING", "모든 필수 약관을 동의해주세요!", "warning");
            }
        }

        if(rtn == "reward") {
            jQuery("#giveaway_start").removeClass("block");
            jQuery("#reward_info").addClass("block");
        }
    }

    function backPage(rtn) {
        if(rtn == "accountInfo") {
            jQuery("#account_info").removeClass("block");
            jQuery("#account_default").addClass("block");
        }

        if(rtn == "accountDefault") {
            jQuery("#mission").children().children().removeClass("clear");
            jQuery("#mission").addClass("block");
            jQuery("#account_default").removeClass("block");
        }

        if(rtn == "mission") {
            jQuery("#giveaway_start").addClass("block");
            jQuery("#mission").removeClass("block");
        }

        if(rtn == "finish") {
            jQuery("#account_default").children().children().removeClass("clear");
            jQuery("#account_default").addClass("block");
            jQuery("#finish").removeClass("block");
        }
    }

    function popupOpen(rtn) {
        if(rtn == "mission") {
            if(jQuery(".mission").length == jQuery(".completion").length) {
                jQuery("#mission_pop").addClass("clear");
            } else {
                swal("WARNING", "모든 미션을 완료해주세요!", "warning");
            }
        } else {
            jQuery("#copy_pop").addClass("clear");
        }
    }

    function closePopup(rtn) {
        if(rtn == "account") {
            jQuery("#account_default").children().children().removeClass("clear");
        } else {rtn == 'question'} {
            jQuery("#question_pop").css("display", "none")
        }
    }

    Kakao.init('035c9add77a88755a9f9835603e5b6f5');
    Kakao.isInitialized();

    //카카오로그인
    function kakaoLogin() {

        Kakao.Auth.login({
            success: function (response) {
                Kakao.API.request({
                    url: '/v2/user/me',
                    success: function (response) {
                        var email = response.kakao_account.email;
                        var phone_number = response.kakao_account.phone_number;

                        if(email) {
                            jQuery('#email').val(email);
                            jQuery("#email").css("color", "white")
                        }

                        if(phone_number) {

                            var phone_data = phone_number.split(" ");
                            var phone = 0 + phone_data[1];
                            jQuery('#phone_number').val(phone)
                            jQuery("#phone_number").css("color", "white")
                            jQuery("#account_default").children().children().addClass("clear");
                        }
                    },
                    fail: function (error) {
                        console.log(error)
                    },
                })
            },
            fail: function (error) {
                console.log(error)
            },
        })
    }

    function completion() {
        var phone = jQuery('#phone_number').val();
        var email = jQuery('#email').val();

        if('' == phone) {
            swal({
                title: "전화번호를 입력해 주세요!",
                text: "전화번호를 입력해 주세요!",
                icon: "error"
            })
        } else if(!chkPhone(phone)) {
            swal({
                title: "전화번호 양식을 확인해 주세요!",
                text: "전화번호 양식을 확인해 주세요!",
                icon: "error"
            })
        } else if ('' == email) {
            swal({
                title: "이메일을 입력해 주세요!",
                text: "이메일을 입력해 주세요!",
                icon: "error"
            })
        } else if(!chkEmail(email)) {
            swal({
                title: "이메일 양식을 확인해 주세요!",
                text: "이메일 양식을 확인해 주세요!",
                icon: "error"
            })

        } else {
            //참여확인
            jQuery.ajax({
                url: '/api/wpGiveawayCheck',
                type: 'post',
                data: {
                    title: object,
                    email: email,
                    phone: phone
                },
                async: false,
                success: function(rtn) {
                    if(rtn > 0) {
                        swal({
                            title: "WARNING",
                            text: "참여 이력이 존재합니다!",
                            type: "warning",
                        }).then( function () {
                            location.href = "https://keychron.kr/giveaway_home/";
                        });

                    } else {
                        jQuery("#account_default").children().children().addClass("clear");
                    }
                }
            });
        }
    }

    function chkEmail(str) {
        var regExp = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;

        if(regExp.test(str)) {
            return true;
        } else {
            return false;
        }
    }

    //  전화번호 유효성 추가
    function chkPhone(str) {
        str = str.replace(/-/gi, '');	// - 제거
        str = str.replace(/\./gi, '');	// . 제거
        str = str.replace(/ /gi, '');	// 공백 제거

        var regExp = /(01[016789])([1-9]{1}[0-9]{2,3})([0-9]{4})$/;

        if(regExp.test(str)) {
            return true;
        } else {
            return false;
        }
    }

    function all_yes() {
        if (jQuery(".all_yes").hasClass("all_chk")) {
            jQuery(".all_yes").removeClass("on");
            jQuery(".all_yes").addClass("off");
            jQuery(".all_yes > .on").css("display", "none");
            jQuery(".all_yes>.off").css("display", "block");
            jQuery(".all_yes").removeClass("all_chk");
            jQuery(".list_chk > .on").css("display", "none");
            jQuery(".list_chk > .off").css("display", "block");
            jQuery(".individual_consent>li>.left_wrap").removeClass("list_chk");

            jQuery(".right_button").removeClass("on");
            jQuery(".right_button").addClass("off");
            jQuery(".right_button").removeAttr("onclick");

            listChkNum = 0;
        } else {
            jQuery(".all_yes").removeClass("off");
            jQuery(".all_yes").addClass("on");
            jQuery(".all_yes > .off").css("display", "none");
            jQuery(".all_yes>.on").css("display", "block");
            jQuery(".all_yes").addClass("all_chk");
            jQuery(".individual_consent>li>.left_wrap").addClass("list_chk");
            jQuery(".list_chk > .off").css("display", "none");
            jQuery(".list_chk > .on").css("display", "block");

            jQuery(".right_button").removeClass("off");
            jQuery(".right_button").addClass("on");
            jQuery(".giveaway_btn").attr("onclick", "giveaway();");

            listChkNum = jQuery(".individual_consent>li").length;
        }
    }

    function listChk(data) {
        if(jQuery(data).hasClass("list_chk")) {
            jQuery(data).find(".off").css("display", "block");
            jQuery(data).find(".on").css("display", "none");
            jQuery(data).removeClass("list_chk");

            listChkNum--;
        } else {
            jQuery(data).find(".off").css("display", "none");
            jQuery(data).find(".on").css("display", "block");
            jQuery(data).addClass("list_chk");
            listChkNum++;
        }

        if(jQuery(".individual_consent>li").length == listChkNum) {
            jQuery(".all_yes").addClass("all_chk");
            jQuery(".all_yes").removeClass("off");
            jQuery(".all_yes").addClass("on");
            jQuery(".all_yes>.off").css("display", "none");
            jQuery(".all_yes>.on").css("display", "block");
            jQuery(".right_button").removeClass("off");
            jQuery(".right_button").addClass("on");

            jQuery(".giveaway_btn").attr("onclick", "giveaway();");
        } else {
            jQuery(".all_yes").removeClass("all_chk");
            jQuery(".all_yes").removeClass("on");
            jQuery(".all_yes").addClass("off");
            jQuery(".all_yes>.off").css("display", "block");
            jQuery(".all_yes>.on").css("display", "none");

            jQuery(".right_button").removeClass("on");
            jQuery(".right_button").addClass("off");

            jQuery(".giveaway_btn").removeAttr("onclick");
        }
    }

    function getParameterByName(name) {
        name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
        var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
            results = regex.exec(location.search);
        return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    }

    function openLink(rtn) {
        if(rtn == 1) {
            window.open("http://gtg.kr/k5qxk");
        } else if (rtn == 2) {
            window.open("http://gtg.kr/f2lj3");
        } else if (rtn == 3) {
            window.open("http://gtg.kr/qua7u");
        } else if (rtn == "insta") {
            window.open("http://gtg.kr/a2g3m");
        } else if (rtn == "kakao") {
            window.open("http://gtg.kr/7gek9");
        } else if (rtn == "home") {
            window.open("https://keychron.kr/giveaway_home/","_self")
        } else {
            window.open(rtn);
        }
    }

    function setDateTimer(timerTime) {
        var reTimerTime = timerTime.replace(/-/gi, "/")
        var nowTime = new Date();
        var endTime = new Date(reTimerTime)
        var diff = endTime - nowTime;

        var diffDay = Math.floor(diff / (1000*60*60*24));
        var diffHour = Math.floor(diff / (1000*60*60) % 24);
        var diffMin = Math.floor(diff / (1000*60) % 60);
        var diffSec = Math.floor(diff / 1000 % 60);

        if (diffHour < 10 && diffHour >= 0) {diffHour = "0" + diffHour;}
        if (diffMin < 10 && diffMin >= 0) {diffMin = "0" + diffMin;}
        if (diffSec < 10 && diffSec >= 0) {diffSec = "0"+diffSec}
        var diffText = diffDay + "일 " + diffHour+ ":" + diffMin + ":" + diffSec + " 남음";

        if(diffHour < 0) {
            jQuery("#timer").text('기간 만료');
        } else {
            jQuery("#timer").text(diffText);
        }


    }

    function copy(){
        var url = '';
        var textarea = document.createElement("textarea");
        document.body.appendChild(textarea);
        url = window.document.location.href;
        textarea.value = url;
        textarea.select();
        document.execCommand("copy");
        document.body.removeChild(textarea);
        alert("링크가 복사되었습니다.")
    }

    jQuery(document).mouseup(function (e){
        var copyPopup = jQuery("#copy_pop");
        if(copyPopup.has(e.target).length === 0){
            copyPopup.removeClass("clear");
        }
    });

    jQuery(document).ready(function () {
        var timerTime = "";


        if(object == "") {
            location.href="https://keychron.kr/giveaway_home/";
        } else {

            jQuery.ajax({
                url: "/api/selectGiveaway",
                type: 'GET',
                dataType: 'json',
                data: {
                    object: object
                },
                success: function (giveawayInfo) {
                    giveawaySeq = giveawayInfo.giveawaySeq;
                    timerTime = giveawayInfo.timerTime;

                    jQuery("#rewardDate").text(giveawayInfo.rewardDate2.substr(2));
                    jQuery("#giveaway_title").text(giveawayInfo.giveawayTitle);
                    jQuery(".rewardUrl").attr("href", giveawayInfo.rewardLink);
                    jQuery(".rewardUrl").attr("target", "_blank");
                    jQuery("#rewardText").text(giveawayInfo.rewardText.replaceAll("<br>","\n"));
                    jQuery("#rewardImageLink").attr("src",giveawayInfo.rewardImageLink);
                    jQuery(".finish_section2").css("background-image","url(" + giveawayInfo.rewardImageLink2 + ")");
                    jQuery("#successText").text(giveawayInfo.successText.replaceAll('<br>', '\n'));

                    var counting_html = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"12\" height=\"12\" viewBox=\"0 0 12 12\">";
                    counting_html +=    "<g id=\"Icon_feather-user\" data-name=\"Icon feather-user\" transform=\"translate(-5 -4)\">";
                    counting_html +=        "<path id=\"패스_28234\" data-name=\"패스 28234\" d=\"M16.991,26.67a.5.5,0,0,1-.509-.5V24.947A1.967,1.967,0,0,0,14.5,23h-6a1.967,1.967,0,0,0-1.982,1.947V26.17a.509.509,0,0,1-1.018,0V24.947A2.977,2.977,0,0,1,8.5,22h6a2.977,2.977,0,0,1,3,2.947V26.17A.5.5,0,0,1,16.991,26.67Z\" transform=\"translate(-0.5 -10.67)\" fill=\"#404040\"/>";
                    counting_html +=        "<path id=\"패스_28235\" data-name=\"패스 28235\" d=\"M14.553,4a3,3,0,0,1,3.053,2.947,3.055,3.055,0,0,1-6.106,0A3,3,0,0,1,14.553,4Zm0,4.894A1.985,1.985,0,0,0,16.57,6.947a2.018,2.018,0,0,0-4.034,0A1.985,1.985,0,0,0,14.553,8.894Z\" transform=\"translate(-3.553 0)\" fill=\"#404040\"/>";
                    counting_html +=    "</g>";
                    counting_html += "</svg>";
                    counting_html += giveawayInfo.count.toLocaleString() + "명 참여";
                    jQuery("#counting").append(counting_html);

                    var reward_html = "";
                    reward_html += "<h4>" + giveawayInfo.rewardTitle  + "</h4>";
                    reward_html += "<p style='height: 120px; width: 170px;'>" + giveawayInfo.rewardText + "</p>";
                    jQuery("#rewardArea").append(reward_html);

                    var reward_html2 = "";
                    reward_html2 += giveawayInfo.rewardTitle;
                    reward_html2 += '<svg class="arrow" xmlns="http://www.w3.org/2000/svg" width="4.752" height="9.412" viewBox="0 0 4.752 9.412">';
                    reward_html2 +=      '<path id="패스_28245" data-name="패스 28245" d="M3277.162,337l3.546,4.007L3277.162,345" transform="translate(-3276.456 -336.294)" fill="none" stroke="#d6d6d6" stroke-linecap="round" stroke-linejoin="round" stroke-width="1" />'
                    reward_html2 += '</svg>';
                    jQuery("#rewardArea2").append(reward_html2);

                    var winner_html = "";
                    winner_html += '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 14 14">';
                    winner_html += '<g id="그룹_1105" data-name="그룹 1105" transform="translate(-16 -439)">';
                    winner_html += '<g id="사각형_8100" data-name="사각형 8100" transform="translate(16 439)" fill="none" stroke="#404040" stroke-width="1">';
                    winner_html += '<rect width="14" height="14" stroke="none"/>';
                    winner_html += '<rect x="0.5" y="0.5" width="13" height="13" fill="none"/>';
                    winner_html += '</g>';
                    winner_html += '<path id="패스_28239" data-name="패스 28239" d="M19.186,447.091l2.923,2.923,5-5" transform="translate(-0.149 -1.512)" fill="none" stroke="#404040" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>';
                    winner_html += '</g>';
                    winner_html += '</svg>';
                    winner_html += giveawayInfo.winnerNum + "명 선정";
                    jQuery("#winnerNum").append(winner_html);

                    if(giveawayInfo.buttonFlag == "Y") {
                        var coupon_html = "";
                        coupon_html += '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="9" viewBox="0 0 14 9">';
                        coupon_html +=      '<g id="그룹_1182" data-name="그룹 1182" transform="translate(-140 -491)">';
                        coupon_html +=          '<g id="사각형_8100" data-name="사각형 8100" transform="translate(140 491)" fill="none" stroke="#404040" stroke-width="1">';
                        coupon_html +=              '<rect width="14" height="9" stroke="none"/>';
                        coupon_html +=              '<rect x="0.5" y="0.5" width="13" height="8" fill="none"/>';
                        coupon_html +=          '</g>';
                        coupon_html +=      '</g>';
                        coupon_html +=  '</svg>';
                        coupon_html +=  "100% 참여 쿠폰";
                        jQuery("#couponFlag").append(coupon_html);
                    }

                    var date = giveawayInfo.startDate.substring(2) + " - " + giveawayInfo.endDate.substring(2);
                    jQuery("#dateRange").text(date)

                    jQuery("#rewardDate").text(giveawayInfo.rewardDate2.substring(2))

                    jQuery.ajax({
                        url: "/event/selectGiveawayEventItemDetail",
                        type: "GET",
                        dataType: 'json',
                        data: {
                            giveawaySeq: giveawaySeq
                        },
                        success: function (giveawayInfo) {

                            if (!giveawayInfo) {
                                location.href="https://keychron.kr/giveaway_home/";
                            }

                            for(var i = 0; i < giveawayInfo.length; i++) {
                                if(giveawayInfo[i].type == "image") {
                                    var html_image = "";
                                    html_image += "<li class='swiper-slide' style='width: 360px;'>";
                                    html_image +=     '<img src="' + giveawayInfo[i].link + '">';
                                    html_image += "</li>";

                                    jQuery("#slide_img").append(html_image);

                                } else {
                                    var html = "";
                                    html += '<li class="missionBorder" onclick="openLink(\'' + giveawayInfo[i].link + '\')">';
                                    html +=     '<a class="mission">';
                                    html +=         '<img src="//tbnws.hgodo.com/giveaway/keychron/Keychron_K8_PRO/completion.png" alt="완료표시아이콘" class="compt">';
                                    html +=         '<img class="logo" src="' + giveawayInfo[i].missionIcon +'">';
                                    html +=         '<h5>' + giveawayInfo[i].missionTitle + '</h5>';
                                    // html +=         '<pre class="pre_style">' + giveawayInfo[i].missionTitle + '</pre>';
                                    html +=         '<img src="//tbnws.hgodo.com/giveaway/keychron/Keychron_K8_PRO/Arrow.png" alt="오른쪽_화살표" class="arrow">';
                                    html +=     '</a>';
                                    html += '</li>';

                                    jQuery("#mission_link").append(html);
                                }
                            }

                            var swiper = new Swiper('.swiper-container', {
                                effect: 'slide',
                                grabCursor: true,
                                centeredSlides: true,
                                slidesPerView: 1,
                                spaceBetween : 0,
                                pagination: {
                                    el: ".swiper-pagination",
                                },
                            });

                            jQuery(".missionBorder").click( function () {
                                jQuery(this).addClass("completion");
                                if(jQuery(".mission").length == jQuery(".completion").length) {
                                    jQuery("#mission_button").addClass("activation");
                                }
                            });


                            jQuery("#phone_number, #email").change(function () {
                                var phoneNumber = jQuery("#phone_number").val();
                                var email = jQuery("#email").val();

                                if (phoneNumber != "" && email != "") {
                                    jQuery("#nextButton").addClass("activation");
                                }
                            });
                        }
                    });
                    setInterval(function() { setDateTimer(timerTime)},1000);
                }, error: function (jqXHR, textStatus, errorThrown) {
                    location.href="https://keychron.kr/giveaway_home/";
                }
            });
        }

        var html = "";
        if(object != "keychron_giveaway14") {
            html += '<a href="https://keychron.kr/giveaway_home/">';
            html +=     '<h3>' + '확인' +'</h3>';
            html += '</a>';

            jQuery("#confirmButton").append(html);
        } else {
            html += '<a href="http://gtg.kr/vce0d">';
            html +=     '<h3>' + '2만원 할인행사 보러가기' +'</h3>';
            html += '</a>';

            jQuery("#confirmButton").append(html);
        }
    });

    openWinnerPopup();
</script>


<style>
    .clear {
        display: block !important;
    }

    .wraps {
        width: 100%;
        z-index: 9999;
    }

    .shadow {
        position: fixed;
        top:0; left: 0; bottom: 0; right: 0;
        background: rgba(0, 0, 0, 0.5);
    }

    #winnerPopup {
        width: 85%;
        background: #FFFFFF 0% 0% no-repeat padding-box;
        box-shadow: 0px 3px 6px #00000029;
        margin: 0 auto;
        transform: translateY(-50%);
        position: relative;
        top: 45%;
        opacity: 1;
        border-radius: 10px !important;
    }

    #winnerTitle {
        text-align: center;
        padding-top: 25px;
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.8px;
        color: #292929;
    }

    #winnerGoods {
        text-align: center;
        padding-top: 5px;
        font-size: 16px;
        font-weight: 500;
        color: #292929;
    }

    #phoneNumArea {
        color: #292929;
        padding-top: 15px;
        font-size: 16px;
        font-weight: 500;
    }

    .area {
        width: 100%;
    }

    #textArea {
        text-align: center;
        padding-top: 25px;
        color: #292929;
        font-size: 15px;
        line-height: 22px;
    }

    #closeWinnerButton {
        border-radius: 10px !important;
        width: 100%;
        height: 50px;
        background-color: black;
        color: #FFFFFF;
    }


</style>



<div class="page-body">

    <div id="giveaway_start" class="block" style="display: none; min-height: 80vh !important; ">
        <div class="all">



            <!-- popup -->
            <!-- div.popup 에 clear 클래스 붙히면 팝업 나옴  -->
            <div class="popup" id="copy_pop">
                <div class="popup_wrap">
                    <img src="//tbnws.hgodo.com/giveaway/keychron/Keychron_K8_PRO/attention.png" alt="느낌표_아이콘">

                    <h2>반드시 크롬, 사파리와 같은<br>별도 브라우저에서 참여해 주세요</h2>
                    <p>카톡, 네이버 등 앱 자체 브라우저에서는 호환성<br>문제로 이벤트 참여가 어려울 수 있습니다.</p>
                    <div class="next_button" id="copy" onclick="copy()">
                        <a>
                            <h3>링크 복사하기</h3>
                        </a>
                    </div>
                    <div class="next_button" id="next_button" onclick="openPage('mission')" style="margin-top: 12px;">
                        <a>
                            <h3>확인</h3>
                        </a>
                    </div>
                </div>
            </div>


            <!-- gt_giveaway_header -->
            <div class="gt_giveaway_header">
                <h1>
                    <svg onclick="openLink('home')" id="group" class="home_icon_btn" xmlns="http://www.w3.org/2000/svg" width="16.158" height="16.2" viewBox="0 0 16.158 16.2">
                        <path id="패스_30517" data-name="패스 30517" d="M8.079,0a.874.874,0,0,1,.588.224l7.224,6.6a.816.816,0,0,1,.267.6v7.948a.843.843,0,0,1-.857.826H10.829a.843.843,0,0,1-.857-.826V10.814H6.186v4.559a.843.843,0,0,1-.857.826H.857A.843.843,0,0,1,0,15.374V7.426a.813.813,0,0,1,.269-.6l7.22-6.6A.876.876,0,0,1,8.079,0Zm7.079,7.511L8.079,1.042,1,7.511V15.2H5.186V10.64a.843.843,0,0,1,.857-.826h4.072a.843.843,0,0,1,.857.826V15.2h4.186Z" transform="translate(0 0)" fill="#676767"/>
                    </svg>
                    <svg xmlns="http://www.w3.org/2000/svg" width="96.75" height="13.032" viewBox="0 0 96.75 13.032">
                        <path id="패스_30518" data-name="패스 30518" d="M-38.583-6.5h2.664v5.112A7.611,7.611,0,0,1-38.295-.2a9.225,9.225,0,0,1-2.718.414,7.366,7.366,0,0,1-3.528-.837A6.231,6.231,0,0,1-47-2.943,6.4,6.4,0,0,1-47.889-6.3,6.4,6.4,0,0,1-47-9.657a6.2,6.2,0,0,1,2.475-2.322,7.51,7.51,0,0,1,3.564-.837,7.8,7.8,0,0,1,3.006.558,5.956,5.956,0,0,1,2.268,1.62L-37.557-8.91a4.33,4.33,0,0,0-3.258-1.422,4.447,4.447,0,0,0-2.142.5,3.616,3.616,0,0,0-1.458,1.422A4.185,4.185,0,0,0-44.937-6.3a4.149,4.149,0,0,0,.522,2.088,3.692,3.692,0,0,0,1.449,1.431,4.3,4.3,0,0,0,2.115.513,4.726,4.726,0,0,0,2.268-.54Zm4.464-6.1H-31.2V0h-2.916Zm17.046,0L-22.527,0h-2.88l-5.436-12.6h3.15l3.834,9,3.888-9Zm9.9,10.26V0h-9.756V-12.6h9.522v2.34h-6.624v2.736h5.85v2.268h-5.85V-2.34Zm9.72-.36H-3.3L-4.419,0H-7.407l5.616-12.6h2.88L6.723,0H3.663ZM1.629-4.914l-2-4.824-2,4.824ZM25.5-12.6,21.375,0H18.243L15.471-8.532,12.609,0H9.495L5.355-12.6H8.379l2.844,8.856,2.97-8.856h2.7l2.88,8.928L22.707-12.6Zm8.6,9.9h-5.85L27.135,0H24.147l5.616-12.6h2.88L38.277,0h-3.06Zm-.918-2.214-2-4.824-2,4.824Zm10.782.45V0H41.049V-4.5l-4.878-8.1h3.1L42.633-7,46-12.6h2.862Z" transform="translate(47.889 12.816)" fill="#292929"/>
                    </svg>
                </h1>
            </div>

            <!-- main -->
            <div class="main1">
                <!-- product_imgs -->
                <div class="slider swiper-container">
                    <ul class="swiper-wrapper" id="slide_img">

                    </ul>
                    <div class="swiper-pagination"></div>
                </div>


                <!-- product_info -->
                <div class="product_info">

                    <h1 readonly="readonly">기브어웨이 리워드</h1>
                    <h2 id="giveaway_title"></h2>
                    <ul>
                        <li>
                            <p id="counting">

                            </p>
                        </li>
                        <li>
                            <div style="width: 150px;">
                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 14 14">
                                    <g id="그룹_1106" data-name="그룹 1106" transform="translate(-140 -407)">
                                        <g id="타원_126" data-name="타원 126" transform="translate(140 407)" fill="none" stroke="#404040" stroke-width="1">
                                            <circle cx="7" cy="7" r="7" stroke="none"/>
                                            <circle cx="7" cy="7" r="6.5" fill="none"/>
                                        </g>
                                        <path id="패스_28236" data-name="패스 28236" d="M2014.688,457l-2.745,2.745v2.645" transform="translate(-1864.943 -45.695)" fill="none" stroke="#404040" stroke-linecap="round" stroke-width="1"/>
                                    </g>
                                </svg>
                                <p id="timer" style="display: inline; letter-spacing: -0.56px; color: #404040; font-weight: normal; vertical-align: text-top; font-size: 14px;"></p>
                            </div>
                        </li>
                        <li>
                            <p id="winnerNum" readonly>

                            </p>
                        </li>
                        <li>
                            <p id="couponFlag" readonly>

                            </p>
                        </li>
                    </ul>

                    <div class="section1">
                        <h3 readonly>기브어웨이 정보</h3>
                        <table border="0" cellspacing="0">
                            <tr>
                                <th>응모기간</th>
                                <td id="dateRange"></td>
                            </tr>
                            <tr>
                                <th>당첨자 발표일</th>
                                <td id="rewardDate"></td>
                            </tr>
                            <tr>
                                <th>리워드 발송일</th>
                                <td>당첨자 별도 안내</td>
                            </tr>
                        </table>
                    </div>

                    <div class="section2">
                        <a class="rewardUrl">
                            <h3>
                                리워드 상세정보
                                <svg xmlns="http://www.w3.org/2000/svg" width="4.752" height="9.412" viewBox="0 0 4.752 9.412">
                                    <path id="패스_54" data-name="패스 54" d="M3277.162,337l3.546,4.007L3277.162,345" transform="translate(-3276.456 -336.294)" fill="none" stroke="#484848" stroke-linecap="round" stroke-linejoin="round" stroke-width="1" />
                                </svg>
                            </h3>
                            <div class="img">
                                <img id="rewardImageLink" alt="행사제품_이미지">
                            </div>
                            <div id="rewardArea" class="text">

                            </div>
                        </a>
                    </div>

                    <div class="common">
                        <h3 class="button">안내사항</h3>
                        <ul>
                            <li>
                                <p style="font-size: 13px;">추첨 결과는 기브어웨이 페이지에 게재됩니다.</p>
                            </li>
                            <li>
                                <p style="font-size: 13px;">미션 미완료 시 당첨이 취소될 수 있습니다.</p>
                            </li>
                            <li>
                                <p style="font-size: 13px;">기브어웨이 당첨자에겐 개별 연락을 드립니다.</p>
                            </li>
                            <li>
                                <p style="font-size: 13px;">당사 사정에 따라 이벤트 내용이 변동될 수 있습니다.</p>
                            </li>
                        </ul>
                    </div>

                </div>

            </div>

            <!-- gt_giveaway_footer -->
            <div class="gt_giveaway_footer">
                <div class="next_button activation" onclick="popupOpen('copy')">
                    <a>
                        <h3>기브어웨이 참여하기</h3>
                    </a>
                </div>
                <div style="width: 100%; text-align: center; height: 40px; line-height: 34px;">
                    <a href="https://brand.naver.com/keychron/shoppingstory/detail?id=2002858667&channelNo=500217403" target="_blank" style="color: #7D7D7D; text-decoration: underline; font-size: 13px;">기브어웨이란?</a>
                </div>
            </div>
        </div>
    </div>




    <div id="mission" style="display: none; min-height: 80vh !important;">
        <div class="all">

            <!-- popup -->
            <!-- div.popup 에 clear 클래스 붙히면 팝업 나옴  -->
            <div class="popup" id="mission_pop">
                <div class="popup_wrap">
                    <img src="//tbnws.hgodo.com/giveaway/keychron/Keychron_K8_PRO/attention.png" alt="느낌표_아이콘">

                    <h2>기브어웨이 미션 참여 시<br>유의사항 안내</h2>
                    <p>당첨자 발표 시점에 미션이 미비돼있을<br>경우 당첨이 취소될 수 있습니다.</p>
                    <div class="next_button" onclick="openPage('account')">
                        <a>
                            <h3>확인</h3>
                        </a>
                    </div>
                </div>
            </div>

            <!-- gt_giveaway_header -->
            <div class="gt_giveaway_header">
                <h1>
                    <svg class="backPoint" xmlns="http://www.w3.org/2000/svg" width="6.431" height="11.996" viewBox="0 0 6.431 11.996" onclick="backPage('mission')">
                        <path id="패스_28247" data-name="패스 28247" d="M3281.593,348a1,1,0,0,1-.748-.336l-4.431-4.989a1,1,0,0,1,0-1.327l4.431-5.007a1,1,0,1,1,1.5,1.325l-3.844,4.343,3.842,4.326a1,1,0,0,1-.747,1.664Z" transform="translate(-3276.161 -336)" fill="#d6d6d6" />
                    </svg>
                    <svg xmlns="http://www.w3.org/2000/svg" width="96.75" height="13.032" viewBox="0 0 96.75 13.032">
                        <path id="패스_30518" data-name="패스 30518" d="M-38.583-6.5h2.664v5.112A7.611,7.611,0,0,1-38.295-.2a9.225,9.225,0,0,1-2.718.414,7.366,7.366,0,0,1-3.528-.837A6.231,6.231,0,0,1-47-2.943,6.4,6.4,0,0,1-47.889-6.3,6.4,6.4,0,0,1-47-9.657a6.2,6.2,0,0,1,2.475-2.322,7.51,7.51,0,0,1,3.564-.837,7.8,7.8,0,0,1,3.006.558,5.956,5.956,0,0,1,2.268,1.62L-37.557-8.91a4.33,4.33,0,0,0-3.258-1.422,4.447,4.447,0,0,0-2.142.5,3.616,3.616,0,0,0-1.458,1.422A4.185,4.185,0,0,0-44.937-6.3a4.149,4.149,0,0,0,.522,2.088,3.692,3.692,0,0,0,1.449,1.431,4.3,4.3,0,0,0,2.115.513,4.726,4.726,0,0,0,2.268-.54Zm4.464-6.1H-31.2V0h-2.916Zm17.046,0L-22.527,0h-2.88l-5.436-12.6h3.15l3.834,9,3.888-9Zm9.9,10.26V0h-9.756V-12.6h9.522v2.34h-6.624v2.736h5.85v2.268h-5.85V-2.34Zm9.72-.36H-3.3L-4.419,0H-7.407l5.616-12.6h2.88L6.723,0H3.663ZM1.629-4.914l-2-4.824-2,4.824ZM25.5-12.6,21.375,0H18.243L15.471-8.532,12.609,0H9.495L5.355-12.6H8.379l2.844,8.856,2.97-8.856h2.7l2.88,8.928L22.707-12.6Zm8.6,9.9h-5.85L27.135,0H24.147l5.616-12.6h2.88L38.277,0h-3.06Zm-.918-2.214-2-4.824-2,4.824Zm10.782.45V0H41.049V-4.5l-4.878-8.1h3.1L42.633-7,46-12.6h2.862Z" transform="translate(47.889 12.816)" fill="#292929"/>
                    </svg>
                </h1>
            </div>

            <!-- wrap -->
            <div class="wrap" style="margin-top: 40px; overflow: scroll !important; height: 450px;">
                <h2>기브어웨이 참여에 필요한<br>모든 미션을 완료해 주세요!</h2>
                <ul id="mission_link">

                </ul>
            </div>


            <!-- footer -->
            <div class="gt_giveaway_footer">
                <div id="mission_button" class="next_button">
                    <a onclick="popupOpen('mission')">
                        <h3>응모하기</h3>
                    </a>
                </div>
            </div>

        </div>
    </div>


    <div id="account_default" style="display: none; min-height: 80vh !important;">
        <div class="all">

            <!-- popup -->
            <!-- div.popup 에 clear 클래스 붙히면 팝업 나옴  -->
            <div class="popup">
                <div class="popup_wrap2">
                    <h3>서비스 이용 동의</h3>
                    <p>기브어웨이 참여를 위해 필수 약관에 동의해 주세요.</p>
                    <a onclick="all_yes()">
                        <div class="all_yes off" id="allYes">
                            <svg class="off" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20">
                                <g id="그룹_1186" data-name="그룹 1186" transform="translate(-42 -354)">
                                    <path id="패스_53" data-name="패스 53" d="M4734.972,130.68l4.222,3.966,6.008-6.6" transform="translate(-4688.086 232.654)" fill="none" stroke="#707070" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" />
                                    <rect id="사각형_7" data-name="사각형 7" width="20" height="20" rx="10" transform="translate(42 354)" fill="none" />
                                </g>
                            </svg>
                            <img src="//tbnws.hgodo.com/giveaway/keychron/Keychron_K8_PRO/completion.png" alt="완료_아이콘" class="on">
                            <h4>전체 동의하기</h4>
                            <svg class="arrow" xmlns="http://www.w3.org/2000/svg" width="6.843" height="12.82" viewBox="0 0 6.843 12.82">
                                <path id="패스_54" data-name="패스 54" d="M3277.161,337l4.431,5.007L3277.161,347" transform="translate(-3275.75 -335.588)" fill="none" stroke="#d6d6d6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" />
                            </svg>
                        </div>
                    </a>
                    <ul class="individual_consent">
                        <li>
                            <div class="left_wrap" onclick="listChk(this)">
                                <svg class="offChk off" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20">
                                    <g id="그룹_1186" data-name="그룹 1186" transform="translate(-42 -354)">
                                        <path id="패스_53" data-name="패스 53" d="M4734.972,130.68l4.222,3.966,6.008-6.6" transform="translate(-4688.086 232.654)" fill="none" stroke="#707070" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" />
                                        <rect id="사각형_7" data-name="사각형 7" width="20" height="20" rx="10" transform="translate(42 354)" fill="none" />
                                    </g>
                                </svg>
                                <img src="//tbnws.hgodo.com/giveaway/keychron/Keychron_K8_PRO/completion.png" alt="완료_아이콘" class="onChk on">
                                <h5>개인정보 활용 동의서</h5>
                            </div>
                            <div class="right_wrap">
                                <a onclick="openPage('eventApproval')">
                                    <svg class="arrow" xmlns="http://www.w3.org/2000/svg" width="6.843" height="12.82" viewBox="0 0 6.843 12.82">
                                        <path id="패스_54" data-name="패스 54" d="M3277.161,337l4.431,5.007L3277.161,347" transform="translate(-3275.75 -335.588)" fill="none" stroke="#d6d6d6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" />
                                    </svg>
                                </a>
                            </div>
                        </li>
                        <li>
                            <div class="left_wrap" onclick="listChk(this)">
                                <svg class="offChk off" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20">
                                    <g id="그룹_1186" data-name="그룹 1186" transform="translate(-42 -354)">
                                        <path id="패스_53" data-name="패스 53" d="M4734.972,130.68l4.222,3.966,6.008-6.6" transform="translate(-4688.086 232.654)" fill="none" stroke="#707070" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" />
                                        <rect id="사각형_7" data-name="사각형 7" width="20" height="20" rx="10" transform="translate(42 354)" fill="none" />
                                    </g>
                                </svg>
                                <img src="//tbnws.hgodo.com/giveaway/keychron/Keychron_K8_PRO/completion.png" alt="완료_아이콘" class="onChk on">
                                <h5>마케팅 정보 이용 약관</h5>
                            </div>
                            <div class="right_wrap">
                                <a onclick="openPage('personalInfo')">
                                    <svg class="arrow" xmlns="http://www.w3.org/2000/svg" width="6.843" height="12.82" viewBox="0 0 6.843 12.82">
                                        <path id="패스_54" data-name="패스 54" d="M3277.161,337l4.431,5.007L3277.161,347" transform="translate(-3275.75 -335.588)" fill="none" stroke="#d6d6d6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" />
                                    </svg>
                                </a>
                            </div>
                        </li>

                    </ul>
                    <div class="button">
                        <a onclick="closePopup('account')">
                            <div class="left_button">
                                <h6>닫기</h6>
                            </div>
                        </a>
                        <a onclick="openPage('finish')">
                            <div class="right_button">
                                <h6>확인</h6>
                            </div>
                        </a>
                    </div>
                </div>
            </div>

            <!-- gt_giveaway_header -->
            <div class="gt_giveaway_header">
                <h1>
                    <svg class="backPoint" xmlns="http://www.w3.org/2000/svg" width="6.431" height="11.996" viewBox="0 0 6.431 11.996" onclick="backPage('accountDefault')">
                        <path id="패스_28247" data-name="패스 28247" d="M3281.593,348a1,1,0,0,1-.748-.336l-4.431-4.989a1,1,0,0,1,0-1.327l4.431-5.007a1,1,0,1,1,1.5,1.325l-3.844,4.343,3.842,4.326a1,1,0,0,1-.747,1.664Z" transform="translate(-3276.161 -336)" fill="#d6d6d6" />
                    </svg>
                    <svg xmlns="http://www.w3.org/2000/svg" width="96.75" height="13.032" viewBox="0 0 96.75 13.032">
                        <path id="패스_30518" data-name="패스 30518" d="M-38.583-6.5h2.664v5.112A7.611,7.611,0,0,1-38.295-.2a9.225,9.225,0,0,1-2.718.414,7.366,7.366,0,0,1-3.528-.837A6.231,6.231,0,0,1-47-2.943,6.4,6.4,0,0,1-47.889-6.3,6.4,6.4,0,0,1-47-9.657a6.2,6.2,0,0,1,2.475-2.322,7.51,7.51,0,0,1,3.564-.837,7.8,7.8,0,0,1,3.006.558,5.956,5.956,0,0,1,2.268,1.62L-37.557-8.91a4.33,4.33,0,0,0-3.258-1.422,4.447,4.447,0,0,0-2.142.5,3.616,3.616,0,0,0-1.458,1.422A4.185,4.185,0,0,0-44.937-6.3a4.149,4.149,0,0,0,.522,2.088,3.692,3.692,0,0,0,1.449,1.431,4.3,4.3,0,0,0,2.115.513,4.726,4.726,0,0,0,2.268-.54Zm4.464-6.1H-31.2V0h-2.916Zm17.046,0L-22.527,0h-2.88l-5.436-12.6h3.15l3.834,9,3.888-9Zm9.9,10.26V0h-9.756V-12.6h9.522v2.34h-6.624v2.736h5.85v2.268h-5.85V-2.34Zm9.72-.36H-3.3L-4.419,0H-7.407l5.616-12.6h2.88L6.723,0H3.663ZM1.629-4.914l-2-4.824-2,4.824ZM25.5-12.6,21.375,0H18.243L15.471-8.532,12.609,0H9.495L5.355-12.6H8.379l2.844,8.856,2.97-8.856h2.7l2.88,8.928L22.707-12.6Zm8.6,9.9h-5.85L27.135,0H24.147l5.616-12.6h2.88L38.277,0h-3.06Zm-.918-2.214-2-4.824-2,4.824Zm10.782.45V0H41.049V-4.5l-4.878-8.1h3.1L42.633-7,46-12.6h2.862Z" transform="translate(47.889 12.816)" fill="#292929"/>
                    </svg>
                </h1>
            </div>

            <!-- main -->
            <div class="main">

                <!-- wrap -->
                <div class="wrap" style="padding-top: 40px;">
                    <h2>이벤트 참여에 필요한<br>필수 정보를 입력하세요.</h2>
                    <a>
                        <div class="easy_registration kakaoButton" onclick="kakaoLogin()">
                            <img src="https://tbnws.hgodo.com/giveaway/gtgear/publishing/img/kakao_logo.png" alt="카카오톡_로고">
                            <h5>KaKao로 간편하게 등록하기</h5>
                        </div>
                    </a>
                    <p>또는<span></span></p>

                    <div class="Personal_information">
                        <ul>
                            <li>
                                <h6>전화번호</h6>
                                <input id="phone_number" placeholder="010-0000-0000">
                            </li>
                            <li>
                                <h6>이메일</h6>
                                <input id="email" placeholder="이메일을 입력해주세요.">
                            </li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- gt_giveaway_footer -->
            <div class="gt_giveaway_footer">
                <div id="nextButton" class="next_button" onclick="completion()">
                    <a>
                        <h3>다음</h3>
                    </a>
                </div>
            </div>
        </div>
    </div>




    <div id="account_info" style="display: none; min-height: 80vh !important;">
        <div class="all">
            <!-- header -->
            <div class="gt_giveaway_header">
                <h1>
                    <svg class="backPoint" xmlns="http://www.w3.org/2000/svg" width="6.431" height="11.996" viewBox="0 0 6.431 11.996" onclick="backPage('accountInfo')">
                        <path id="패스_28247" data-name="패스 28247" d="M3281.593,348a1,1,0,0,1-.748-.336l-4.431-4.989a1,1,0,0,1,0-1.327l4.431-5.007a1,1,0,1,1,1.5,1.325l-3.844,4.343,3.842,4.326a1,1,0,0,1-.747,1.664Z" transform="translate(-3276.161 -336)" fill="#d6d6d6" />
                    </svg>
                    <svg xmlns="http://www.w3.org/2000/svg" width="96.75" height="13.032" viewBox="0 0 96.75 13.032">
                        <path id="패스_30518" data-name="패스 30518" d="M-38.583-6.5h2.664v5.112A7.611,7.611,0,0,1-38.295-.2a9.225,9.225,0,0,1-2.718.414,7.366,7.366,0,0,1-3.528-.837A6.231,6.231,0,0,1-47-2.943,6.4,6.4,0,0,1-47.889-6.3,6.4,6.4,0,0,1-47-9.657a6.2,6.2,0,0,1,2.475-2.322,7.51,7.51,0,0,1,3.564-.837,7.8,7.8,0,0,1,3.006.558,5.956,5.956,0,0,1,2.268,1.62L-37.557-8.91a4.33,4.33,0,0,0-3.258-1.422,4.447,4.447,0,0,0-2.142.5,3.616,3.616,0,0,0-1.458,1.422A4.185,4.185,0,0,0-44.937-6.3a4.149,4.149,0,0,0,.522,2.088,3.692,3.692,0,0,0,1.449,1.431,4.3,4.3,0,0,0,2.115.513,4.726,4.726,0,0,0,2.268-.54Zm4.464-6.1H-31.2V0h-2.916Zm17.046,0L-22.527,0h-2.88l-5.436-12.6h3.15l3.834,9,3.888-9Zm9.9,10.26V0h-9.756V-12.6h9.522v2.34h-6.624v2.736h5.85v2.268h-5.85V-2.34Zm9.72-.36H-3.3L-4.419,0H-7.407l5.616-12.6h2.88L6.723,0H3.663ZM1.629-4.914l-2-4.824-2,4.824ZM25.5-12.6,21.375,0H18.243L15.471-8.532,12.609,0H9.495L5.355-12.6H8.379l2.844,8.856,2.97-8.856h2.7l2.88,8.928L22.707-12.6Zm8.6,9.9h-5.85L27.135,0H24.147l5.616-12.6h2.88L38.277,0h-3.06Zm-.918-2.214-2-4.824-2,4.824Zm10.782.45V0H41.049V-4.5l-4.878-8.1h3.1L42.633-7,46-12.6h2.862Z" transform="translate(47.889 12.816)" fill="#292929"/>
                    </svg>
                </h1>
            </div>

            <!-- wrap1 -->
            <div class="wrap1">
                <div class="Terms_of_Use">
                    <div id="eventApproval" style="display: none;">
                        <h3>이벤트 참여를 위한 동의사항</h3>
                        <p>본 약관은 (주) 투비네트웍스글로벌(이하 회사)이 주최하는 모든 이벤트에 적용됩니다.<br>
                            ‘이벤트’를 통한 경품의 증정 내용, 증정 조건, 기한 등은 개별 이벤트의 공지 내용에서 정한 바에 따릅니다.<br>
                            참여자는 ‘이벤트’에 응모한 ‘게시물’ 혹은 ‘미션’을 최소 6개월간 공개 또는 유지된 상태로 게시하여야 합니다. 경품 수령 이후 등록한 ‘게시물’을 비공개처리하는 경우 또는 개인정보 수집 동의를 철회하는 경우, 수령한 경품을 반환하여야 합니다.<br>
                            ‘이벤트’에 등록된 ‘게시물’은 ‘회사’가 활용하여 광고를 진행할 수 있으며, 참여자가 응모한 게시글 및 콘텐츠가 공개적으로 노출될 수 있습니다. 이 경우 ‘회사’가 ‘게시물’을 복제, 배포, 전송하여 광고에 활용될 수 있습니다.<br>
                            ‘이벤트’ 참여를 위해 등록하는 ‘게시물’의 내용은 타인의 저작권 및 초상 권리를 침해하지 않아야 하며, 이를 위반할 경우 응모가 취소될 수 있습니다.<br>
                            참여자가 응모하는 개인정보에 오류가 있는 경우, 경품 미발송으로 인한 불이익을 보상받을 수 없습니다. 또한 경품은 교환 또는 환불이 불가능합니다.<br>
                        </p>
                    </div>

                    <div id="personalInfo" style="display: none;">
                        <h3>개인정보 수집 / 이용 안내</h3>

                        <p>개인정보 수집/이용 목적<br>
                            - 이벤트 접수, 본인확인, 이벤트 경품 제공<br>
                            - 베스트 게시물 선정, ‘회사’의 광고물 제작
                        </p>

                        <p>
                            개인정보 수집/이용 항목<br>
                            (필수) 휴대폰 번호, 전자우편 주소<br>
                            *추후 당첨자 발표 시 사은품 배송을 위한 추가 정보를 요청할 수 있습니다.
                        </p>

                        <p>
                            이용 및 보유기간<br>
                            -  이벤트 종료 시점으로부터 2년간 이용 가능합니다.<br>
                            * 이용자는 개인정보 수집/이용을 거부할 수 있습니다. 단, ‘필수’ 항목에 대한 동의를 거부하는 경우 이벤트 참여 등록이 제한됩니다*
                        </p>
                    </div>

                </div>
            </div>

            <!-- footer -->
            <footer class="Terms_of_Use_footer">
                <div class="blank_space">
                </div>
            </footer>

        </div>
    </div>





    <div id="finish" style="display: none; min-height: 80vh !important;">
        <div class="all">
            <!-- popup -->

            <!-- header -->
            <div class="gt_giveaway_header">
                <h1>
                    <svg xmlns="http://www.w3.org/2000/svg" width="6.431" height="11.996" viewBox="0 0 6.431 11.996" style="display: none;">
                        <path id="패스_28247" data-name="패스 28247" d="M3281.593,348a1,1,0,0,1-.748-.336l-4.431-4.989a1,1,0,0,1,0-1.327l4.431-5.007a1,1,0,1,1,1.5,1.325l-3.844,4.343,3.842,4.326a1,1,0,0,1-.747,1.664Z" transform="translate(-3276.161 -336)" fill="#d6d6d6" />
                    </svg>
                    <svg xmlns="http://www.w3.org/2000/svg" width="96.75" height="13.032" viewBox="0 0 96.75 13.032">
                        <path id="패스_30518" data-name="패스 30518" d="M-38.583-6.5h2.664v5.112A7.611,7.611,0,0,1-38.295-.2a9.225,9.225,0,0,1-2.718.414,7.366,7.366,0,0,1-3.528-.837A6.231,6.231,0,0,1-47-2.943,6.4,6.4,0,0,1-47.889-6.3,6.4,6.4,0,0,1-47-9.657a6.2,6.2,0,0,1,2.475-2.322,7.51,7.51,0,0,1,3.564-.837,7.8,7.8,0,0,1,3.006.558,5.956,5.956,0,0,1,2.268,1.62L-37.557-8.91a4.33,4.33,0,0,0-3.258-1.422,4.447,4.447,0,0,0-2.142.5,3.616,3.616,0,0,0-1.458,1.422A4.185,4.185,0,0,0-44.937-6.3a4.149,4.149,0,0,0,.522,2.088,3.692,3.692,0,0,0,1.449,1.431,4.3,4.3,0,0,0,2.115.513,4.726,4.726,0,0,0,2.268-.54Zm4.464-6.1H-31.2V0h-2.916Zm17.046,0L-22.527,0h-2.88l-5.436-12.6h3.15l3.834,9,3.888-9Zm9.9,10.26V0h-9.756V-12.6h9.522v2.34h-6.624v2.736h5.85v2.268h-5.85V-2.34Zm9.72-.36H-3.3L-4.419,0H-7.407l5.616-12.6h2.88L6.723,0H3.663ZM1.629-4.914l-2-4.824-2,4.824ZM25.5-12.6,21.375,0H18.243L15.471-8.532,12.609,0H9.495L5.355-12.6H8.379l2.844,8.856,2.97-8.856h2.7l2.88,8.928L22.707-12.6Zm8.6,9.9h-5.85L27.135,0H24.147l5.616-12.6h2.88L38.277,0h-3.06Zm-.918-2.214-2-4.824-2,4.824Zm10.782.45V0H41.049V-4.5l-4.878-8.1h3.1L42.633-7,46-12.6h2.862Z" transform="translate(47.889 12.816)" fill="#292929"/>
                    </svg>
                </h1>
            </div>

            <!-- main -->
            <div class="main">

                <!-- finish_wrap -->
                <div class="finish_wrap">

                    <h2>기브어웨이 참여 완료!</h2>
                    <p id="successText"></p>
                    <div class="finish_section1">
                        <ul>
                            <li class="href" onclick="openLink('1')">
                                <svg class="icon" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="18" height="18" viewBox="0 0 18 18">
                                    <defs>
                                        <clipPath id="clip-path">
                                            <rect id="사각형_12533" data-name="사각형 12533" width="18" height="18" transform="translate(0 0)" fill="#404040"/>
                                        </clipPath>
                                    </defs>
                                    <g id="그룹_1986" data-name="그룹 1986" transform="translate(0 0)">
                                        <g id="그룹_1985" data-name="그룹 1985" transform="translate(0 0)" clip-path="url(#clip-path)">
                                            <path id="패스_30519" data-name="패스 30519" d="M17.948.5H.836A.336.336,0,0,0,.5.836V17.948a.336.336,0,0,0,.336.336H17.948a.336.336,0,0,0,.336-.336V.836A.336.336,0,0,0,17.948.5ZM4.968,4.844V2.572a.5.5,0,0,1,1.007,0V4.844a3.417,3.417,0,0,0,6.834,0V2.572a.5.5,0,0,1,1.007,0V4.844a4.424,4.424,0,1,1-8.848,0ZM16.324,16.478h-1.14l-1.954-2.4v2.4H11.914V12.44h1.14l1.954,2.443V12.44h1.315Z" transform="translate(-0.392 -0.392)" fill="#404040"/>
                                        </g>
                                    </g>
                                </svg>
                                <h3>브랜드<br>스토어</h3>
                                <svg class="arrow" xmlns="http://www.w3.org/2000/svg" width="4.752" height="9.412" viewBox="0 0 4.752 9.412">
                                    <path id="패스_28245" data-name="패스 28245" d="M3277.162,337l3.546,4.007L3277.162,345" transform="translate(-3276.456 -336.294)" fill="none" stroke="#d6d6d6" stroke-linecap="round" stroke-linejoin="round" stroke-width="1" />
                                </svg>
                            </li>
                            <li class="href" onclick="openLink('2')">
                                <svg class="icon" xmlns="http://www.w3.org/2000/svg" width="17" height="17" viewBox="0 0 17 17">
                                    <path id="Icon_awesome-instagram" data-name="Icon awesome-instagram" d="M8.5,6.379a4.359,4.359,0,1,0,4.358,4.359A4.351,4.351,0,0,0,8.5,6.379Zm0,7.192a2.834,2.834,0,1,1,2.833-2.834A2.838,2.838,0,0,1,8.5,13.571ZM14.049,6.2a1.016,1.016,0,1,1-1.016-1.017A1.014,1.014,0,0,1,14.049,6.2Zm2.886,1.032a5.032,5.032,0,0,0-1.373-3.562A5.062,5.062,0,0,0,12,2.3c-1.4-.08-5.609-.08-7.012,0A5.055,5.055,0,0,0,1.427,3.667,5.048,5.048,0,0,0,.054,7.229c-.08,1.4-.08,5.61,0,7.014A5.032,5.032,0,0,0,1.427,17.8a5.069,5.069,0,0,0,3.561,1.373c1.4.08,5.609.08,7.012,0A5.029,5.029,0,0,0,15.562,17.8a5.065,5.065,0,0,0,1.373-3.562c.08-1.4.08-5.607,0-7.01Zm-1.813,8.516a2.869,2.869,0,0,1-1.616,1.616c-1.119.444-3.774.341-5.01.341s-3.895.1-5.01-.341a2.869,2.869,0,0,1-1.616-1.616c-.444-1.119-.341-3.774-.341-5.011s-.1-3.9.341-5.011A2.869,2.869,0,0,1,3.487,4.111c1.119-.444,3.774-.341,5.01-.341s3.895-.1,5.01.341a2.869,2.869,0,0,1,1.616,1.616c.444,1.119.341,3.774.341,5.011S15.566,14.633,15.122,15.749Z" transform="translate(0.005 -2.238)" fill="#404040"/>
                                </svg>
                                <h3>공식<br>인스타그램</h3>
                                <svg class="arrow" xmlns="http://www.w3.org/2000/svg" width="4.752" height="9.412" viewBox="0 0 4.752 9.412">
                                    <path id="패스_28245" data-name="패스 28245" d="M3277.162,337l3.546,4.007L3277.162,345" transform="translate(-3276.456 -336.294)" fill="none" stroke="#d6d6d6" stroke-linecap="round" stroke-linejoin="round" stroke-width="1" />
                                </svg>
                            </li>
                            <li class="href" onclick="openLink('3')">
                                <img src="/wp-content/uploads/2019/09/youtube_icon.png" style="vertical-align: text-top !important;">
                                <h3>공식<br>유튜브</h3>
                                <svg class="arrow" xmlns="http://www.w3.org/2000/svg" width="4.752" height="9.412" viewBox="0 0 4.752 9.412">
                                    <path id="패스_28245" data-name="패스 28245" d="M3277.162,337l3.546,4.007L3277.162,345" transform="translate(-3276.456 -336.294)" fill="none" stroke="#d6d6d6" stroke-linecap="round" stroke-linejoin="round" stroke-width="1" />
                                </svg>
                            </li>
                        </ul>
                    </div>

                    <div class="finish_section2" style="background-size: cover;">

                        <a class="rewardUrl">
                            <h3>리워드 제품 상세정보</h3>
                            <p id="rewardArea2">

                            </p>
                        </a>
                    </div>
                </div>

            </div>

            <!-- footer2 -->
            <div class="gt_giveaway_footer2">
                <div class="next_button activation" id="confirmButton">

                </div>
                <p><a href="https://keychron.kr/giveaway_home/">홈으로 돌아가기</a></p>
            </div>

        </div>
    </div>
</div>
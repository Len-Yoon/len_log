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

    // 191101. KimGoon. 전화번호 유효성 추가
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
                url: "/event/selectGiveaway",
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
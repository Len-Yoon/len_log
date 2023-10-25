
<script>
    //고유 url을 입력해 주세요!
    var object = '';

    //프리런칭 제목을 입력해 주세요!
    var title1 = '';

    var prelaunchingQna = "";
    var prelaunchingFlag = "N";
    var userName = "";
    var userPhone = "";
    var userMail = "";
    var seq = "";
    var option22 = 'Y';
    var brandCode = 'brd0029';

    function openPopup() {
        jQuery("#title1").text(title1);
        jQuery("#title2").text(title1 + " 옵션선택");
        jQuery("#option1").html('');
        jQuery("#option2").html('');
        var html11 = "<option value='' disabled selected>첫 번째 옵션을 선택해 주세요!</option>";
        jQuery("#option1").append(html11);
        var html22 = "<option value='' disabled selected>두 번째 옵션을 선택해 주세요!</option>";
        jQuery("#option2").append(html22);
        prelaunchingQna = "";
        prelaunchingFlag = "N";

        jQuery("#prelaunching-start").addClass("clear");
        jQuery("#prelaunching-option").removeClass("clear");
        jQuery(".wrap").addClass("shadow");
        jQuery("#prelaunchingFlag").prop("checked", false);

        jQuery("#userPhone").val("");
        jQuery("#userMail").val("");

        jQuery("#the7-body").css("overflow", "hidden");

        jQuery("#marketingFlag").prop("checked", true);
        jQuery("#marketing_checked").css("display", "block");
        jQuery("#marketing_no_check").css("display", "none");

        jQuery("#prelaunchingFlag").prop("checked", false);
        jQuery("#pre_checked").css("display", "none");
        jQuery("#pre_no_check").css("display", "block");

    }

    function openSecondPopup() {
        userName = "";
        userPhone = jQuery("#userPhone").val().replaceAll("-", "").replaceAll(" ", "");
        userMail = jQuery("#userMail").val();

        if (!userPhone) {
            alert("전화번호를 입력해 주세요!");
            return;
        } else if (!userMail) {
            alert("이메일을 입력해 주세요!");
            return;
        } else if (!chkPhone(userPhone)) {
            alert("전화번호 양식을 확인해 주세요!");
            return;
        } else if (!chkEmail(userMail)) {
            alert("이메일 양식을 확인해 주세요!");
            return;
        } else {
            if(!jQuery("#marketingFlag").is(':checked')) {
                alert("마케팅 활용 동의를 해주세요!");
                return;
            } else {
                jQuery.ajax({
                    type: 'GET',
                    url: '/event/checkPrelaunching',
                    data: {
                        object: object,
                        email: userMail,
                        phone: userPhone
                    },
                    async: false,
                    success: function (count) {
                        if(count != 0) {
                            alert("참여 이력이 존재합니다!");
                            return;
                        } else {
                            if(jQuery("#prelaunchingFlag").is(':checked')) {
                                prelaunchingFlag = 'Y';

                                jQuery("#prelaunching-start").removeClass("clear");
                                // jQuery("#prelaunching-end").addClass("clear");
                                jQuery("#prelaunching-option").addClass("clear");
                                jQuery("#phone").text(userPhone);
                                jQuery("#email").text(userMail);

                                jQuery("#preFlag").text("참여")

                            } else {
                                jQuery("#second_popup").addClass("clear");
                                jQuery(".wrap2").addClass("shadow");
                            }

                            jQuery.ajax({
                                type: 'GET',
                                url: '/event/selectPrelaunchingOption1List',
                                data: {
                                    object: object,
                                },
                                dataType: 'json',
                                async: false,
                                success: function (rtn3) {
                                    var html = "<option value='' disabled selected>첫번 째 옵션을 선택해 주세요!</option>";

                                    for (var i = 0; i < rtn3.length; i++) {
                                        html += "<option value='"+ rtn3[i].frame +"'>" + rtn3[i].frame + "</option>";
                                    }

                                    jQuery("#option1").append(html);
                                }
                            });
                        }
                    }
                });
            }
        }
    }

    function closeOptionPopup() {
        var option1 = jQuery("#option1 option:selected").val();
        var option2 = jQuery("#option2 option:selected").val();

        if(!option1) {
            alert("모든 옵션을 선택해 주세요!");
            return;
        } else if (option2 == 'N') {
            if(!option2) {
                alert("모든 옵션을 선택해 주세요!");
                return;
            } else {
                jQuery.ajax({
                    type: 'GET',
                    url: '/event/insertPrelaunchingUserInfo',
                    data: {
                        object: object,
                        email: userMail,
                        phone: userPhone,
                        prelaunchingFlag: prelaunchingFlag,
                        option1: option1,
                        option2: option2,
                        brandCode: brandCode
                    },
                    async: false,
                    success: function (rtn) {
                        jQuery("#prelaunching-option").removeClass("clear");
                        jQuery("#prelaunching-end").addClass("clear");

                        jQuery("#preOption1").text(option1);
                        jQuery("#preOption2").text(option2);
                    }
                });
            }

        } else {

            jQuery.ajax({
                type: 'GET',
                url: '/event/insertPrelaunchingUserInfo',
                data: {
                    object: object,
                    email: userMail,
                    phone: userPhone,
                    prelaunchingFlag: prelaunchingFlag,
                    option1: option1,
                    option2: option2,
                    brandCode: brandCode
                },
                async: false,
                success: function (rtn) {
                    jQuery("#prelaunching-option").removeClass("clear");
                    jQuery("#prelaunching-end").addClass("clear");

                    jQuery("#preOption1").text(option1);
                    jQuery("#preOption2").text(option2);
                }
            });
        }


    }

    function closeSecondPopup(rtn) {

        if (rtn == 'close') {
            jQuery("#prelaunching-start").removeClass("clear");
            jQuery("#second_popup").removeClass("clear");
            jQuery(".wrap2").removeClass("shadow");
            // jQuery("#prelaunching-end").addClass("clear");
            jQuery("#prelaunching-option").addClass("clear");

            jQuery("#phone").text(userPhone);
            jQuery("#email").text(userMail);
        } else {
            prelaunchingFlag = 'Y';
            jQuery("#prelaunching-start").removeClass("clear");
            jQuery("#second_popup").removeClass("clear");
            jQuery(".wrap2").removeClass("shadow");
            // jQuery("#prelaunching-end").addClass("clear");
            jQuery("#prelaunching-option").addClass("clear");

            jQuery("#name").text(userName);
            jQuery("#phone").text(userPhone);
            jQuery("#email").text(userMail);
            jQuery("#preFlag").text("참여");

        }
    }

    function openQna() {
        jQuery(".wrap4").addClass("shadow");
        jQuery("#third_popup").addClass("clear");
    }

    function closeQna() {
        jQuery(".wrap4").removeClass("shadow");
        jQuery("#third_popup").removeClass("clear");

    }

    function openQuestionMark() {
        jQuery("#qna_popup").addClass("clear");
        jQuery(".wrap1").addClass("shadow");
    }

    function closeQuestionMark(rtn) {
        if(rtn == "close") {
            jQuery("#qna_popup").removeClass("clear");
            jQuery(".wrap1").removeClass("shadow");
            prelaunchingQna = "N"
            jQuery("#prelaunchingFlag").prop("checked", false);
            jQuery("#pre_checked").css("display", "none");
            jQuery("#pre_no_check").css("display", "block");
        } else {
            jQuery("#qna_popup").removeClass("clear");
            jQuery(".wrap1").removeClass("shadow");
            jQuery("#prelaunchingFlag").prop("checked", true);
            jQuery("#pre_checked").css("display", "block");
            jQuery("#pre_no_check").css("display", "none");

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

    function closeModal(rtn) {
        if(rtn == 'first')  {
            jQuery("#prelaunching-start").removeClass("clear");
            jQuery(".wrap").removeClass("shadow");

            jQuery("#the7-body").css("overflow", "");

        } else if (rtn == 'second') {
            jQuery("#prelaunching-option").removeClass("clear");
            jQuery(".wrap").removeClass("shadow");

            jQuery("#the7-body").css("overflow", "");
        }else {
            jQuery("#prelaunching-end").removeClass("clear");
            jQuery(".wrap").removeClass("shadow");

            jQuery("#the7-body").css("overflow", "");

            window.location.reload();
        }

    }

    function checkbox_change(rtn) {

        if(rtn == "marketingChk") {
            jQuery("#marketingFlag").prop("checked", false);
            jQuery("#marketing_checked").css("display", "none");
            jQuery("#marketing_no_check").css("display", "block");
        } else if (rtn == "marketingNoChk") {
            jQuery("#marketingFlag").prop("checked", true);
            jQuery("#marketing_checked").css("display", "block");
            jQuery("#marketing_no_check").css("display", "none");
        } else if (rtn == "preChk") {
            jQuery("#prelaunchingFlag").prop("checked", true);
            jQuery("#pre_checked").css("display", "block");
            jQuery("#pre_no_check").css("display", "none");
        } else if (rtn == "preNochk") {
            jQuery("#prelaunchingFlag").prop("checked", false);
            jQuery("#pre_checked").css("display", "none");
            jQuery("#pre_no_check").css("display", "block");
        }
    }

    function openApprovalModal() {
        jQuery("#showTerms").addClass("clear");
        jQuery(".wrap3").addClass("shadow");

        var html = '<개인정보취급방침><br><br>키크론 뉴스레터 서비스 제공 및 이용과 관련하여 주식회사 투비네트웍스글로벌이 취득한 개인정보는 ＂통신비밀보호법＂, ' +
            '＂전기통신사업법＂ 및 ＂정보통신망 이용촉진 및 정보보호 등에 관한 법률＂ 등 정보통신서비스제공자가 준수하여야 할 관련 법령상의 개인정보 보호 규정을 준수합니다.<br><br>1. 개인정보 취급방침' +
            '<br><br>1. 용어의 정의<br>뉴스레터: 주식회사 투비네트웍스글로벌이 전자적 전송 매체(SMS/MMS/e-mail/App Push. 등 다양한 전송 매체)를 통하여 발송하는 컨텐츠 일체<br>구독 신청자:  ' +
            '뉴스레터 서비스를 희망하여 개인 정보를 제공하는 주체<br><br>2. 개인정보의 개념, 수집 목적과 수집 범위<br>개인정보의 개념<br>개인정보라 함은 생존하는 개인에 관한 정보로 당해 정보에 ' +
            '포함되어 있는 성명, 휴대폰 번호, 이메일 등의 사항에 의하여 개인을 식별할 수 있는 정보<br>(당해 정보만으로는 특정 개인을 식별할 수 없더라도 다른 정보와 용이하게 결합하여 식별할 수 있는 것을 포함)' +
            '<br><br>2) 수집 목적 <br>- 뉴스레터 발송 및 구독 관리<br>- 고지사항 전달, 불만처리 등을 위한 원활한 의사소통 경로의 확보<br>- 뉴스레터 관련 설문조사<br>- 새로운 서비스, 이벤트, 마케팅, 광고성 ' +
            '정보 등의 안내<br>- 이벤트 당첨자의 정보 확인 (연락처, 주소 등)<br><br>3) 범위<br>뉴스레터 구독 신청자의 성명, 휴대폰 번호, 이메일 등<br>이벤트, 오프라인 행사 등 각종 서비스 제공 시 추가 정보 ' +
            '(연락처, 주소 등)<br>IP 주소, 쿠키, MAC 주소, 서비스 이용 기록, 방문 기록, 불량 이용 기록 등 (신규 서비스 개발, 개별 맞춤 서비스 제공 목적)<br><br>3. 개인정보 수집에 대한 동의<br>' +
            '마케팅 활용 동의 후 키크론 뉴스레터 프리런칭 신청 시 개인정보 수집 및 활용에 동의한 것으로 간주<br><br>4. 개인정보의 보유 및 이용기간 및 파기<br>별도 동의 철회 시 또는 서비스 제공 종료시까지' +
            '<br>단, 관계법령의 규정에 따라 보존할 필요가 있을 경우, 해당 기간까지 보존<br>보유 및 이용기간 이후에는 해당 정보를 지체 없이 파기<br>전자적 파일  형태의 개인정보 :  기록을 재생할 수 없도록 ' +
            '로우 레벨 포맷<br>종이 문서 형태의 개인정보 : 분쇄기로 분쇄하거나 소각<br><br>2. 개인 정보의 제3자 제공 및 활용에 대한 동의<br><br>1) 주식회사 투비네트웍스글로벌은 구독 신청자의 개인정보를 ' +
            '개인정보의 수집 목적에 관하여만 취급하며, 정보주체의 동의, 법률의 특별한 규정 등의 경우에만 개인정보를 제3자에게 제공합니다.<br><br>2) 주식회사 투비네트웍스 글로벌은 원활한 서비스 제공을 위하여 ' +
            '수집한 정보 중 일부를 제3자인 슬로워크(스티비)에게 제공하고 있으며 정보 제공 외의 목적으로 사용하지 않습니다. <br>주식회사 투비네트웍스글로벌은 개인 정보를 제공 받는 자가 관련 법령에 따라 ' +
            '개인정보를 안전하게 취급하도록 관리/감독하고 있습니다.<br>- 개인 정보를 제공 받는 자 : ㈜슬로워크(스티비)<br>제공 목적 : 키크론 프리런칭 뉴스레터 등 컨텐츠 발송 및 구독자 이벤트, 행사 등 ' +
            '안내<br>- 제공 항목 : 이메일, 휴대폰 번호<br>- 제공 받는 자의 보유 및 이용기간 : 구독 신청자의 도의 철회 시까지 또는 서비스 종료 시까지<br>3. 개인정보의 안전성 확보 조치<br><br>' +
            '주식회사 투비네트웍스 글로벌은 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다.<br><br>1) 관리적 조치<br>- 내부관리계획 수립, 시행, 정기적 직원 교육 등<br><br>2) ' +
            '기술적 조치<br>- 개인정보처리시스템 증의 접근권한 관리, 접근통제시스템 설치, 고유식별정보 등의 암호화, 보안프로그램 설치<br><br>3) 물리적 조치<br>- 전산실, 자료 보관실 등의 접근 통제' +
            '<br><br>4. 개인정보보호 책임자<br><br>① 주식회사 투비네트웍스 글로벌은 개인정보처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 구독 신청자의 불만처리 및 피해 구체 등을 위하여 ' +
            '아래와 같이 개인정보 보호 책임자를 지정하고 있습니다.<br><br>- 개인정보보호담당자<br>성명	김기태<br>직책	개발팀장<br>연락처	 1833-6807<br>(e-mail: support@gtgear.co.kr)' +
            '<br><br>② 구독 신청자는 서비스 이용중 발생한 모든 개인정보보호관련 문의, 불만처리, 피해구제 등에 관한 사항을 개인정보 보호책임자 및 담당부서로 문의할 수 있습니다. 주식회사 투비네트웍스글로벌은 ' +
            '문의에 대해 지체 없이 답변 및 처리하고 있습니다.<br><br>5. 구독 신청자의 권리·의무 및 행사방법 및 쿠키운영<br><br>① 구독 신청자는 주식회사 투비네트웍스글로벌에 대해 언제든지 다음 각 호의 ' +
            '개인정보 보호 관련 권리를 행사할 수 있습니다. 단, 만14세 미만 아동의 경우 그 법정대리인이 아동의 개인정보에 관한 권리를 행사할 수 있습니다.<br>1. 개인정보 열람 요구<br>2. 오류 등이 있을 ' +
            '경우 정정 요구<br>3. 삭제 요구<br>4. 처리 정지 요구<br><br>② 제1항에 따른 권리 행사는 주식회사 투비네트웍스글로벌에 대해 서면, 전화, 전자우편 등을 통하여 가능합니다.<br><br>③ ' +
            '구독 신청자가 개인정보의 오류 등에 대한 정정 또는 삭제를 요구한 경우에는 주식회사 투비네트웍스 글로벌은 정정 또는 삭제를 완료할 때까지 당해 개인정보를 이용하거나 제공하지 않습니다.<br><br>' +
            '④ 제1항에 따른 권리 행사는 구독 신청자의 법정대리인이나 위임을 받은 자 등 대리인을 통하여 가능합니다.  이 경우, 개인정보 보호법 시행규칙 별지 제11호 서식에 따른 위임장을 제출하셔야 합니다.' +
            '<br><br>⑤ 구독 신청자는 개인정보 보호법 등 관계법령을 위반하여 주식회사 투비네트웍스글로벌이 처리하고 있는 본인이나 타인의 개인정보 및 사생활을 침해할 수 없습니다.<br><br>' +
            '⑥ 구독 신청자는 웹브라우저에서 옵션을 설정함으로써 모든 쿠키를 허용하거나, 저장을 거부할 수도 있습니다. 다만 쿠키 설치를 거부할 경우 웹 사용이 불편해질 수 있습니다.<br><br>*설정 방법의 예<br>' +
            '(1) Internet Explorer : 웹 브라우저 상단 모두 메뉴 > 인터넷 옵션 > 개인정보 > 설정<br>(2) Chrome : 웹 브라우저 우측의 설정 메뉴 > 화면 하단의 고급 설정 표시 > 개인정보의 콘텐츠 설정 버튼 > ' +
            '쿠키<br><br>6. 정책 변경에 따른 고지<br>주식회사 투비네트웍스글로벌은 현 개인정보취급방침의 내용 추가, 삭제 및 수정이 있을 시 구독자에게 개정 7일 전 고지를 원칙으로 합니다.<br><br>' +
            '- 현 개인정보보호정책의 시행 일자: 2019년 1월 1일<br>';

        jQuery("#termsBody").html(html);
        ;    }

    function closeTerms() {
        jQuery("#showTerms").removeClass("clear");
        jQuery(".wrap3").removeClass("shadow");
    }

    jQuery(document).ready(function () {
        jQuery("#openButton").on('click', function () {
            openPopup();

            jQuery.ajax({
                type: 'GET',
                url: '/event/selectPrelaunchingOption2List',
                data: {
                    option1: "",
                    object: object
                },
                async: false,
                dataType: 'json',
                success: function (rtn) {
                    if(rtn[0].option == '') {
                        jQuery(".option22").css("display", "none");

                        option22 == "N";
                    }

                }
            });
        });

        jQuery('#option1').on('change', function() {
            jQuery("#option2").empty();
            var option1 = jQuery("#option1 option:selected").val();

            jQuery.ajax({
                type: 'GET',
                url: '/event/selectPrelaunchingOption2List',
                data: {
                    option1: option1,
                    object: object
                },
                async: false,
                dataType: 'json',
                success: function (rtn) {
                    var html = "<option value='' disabled selected>두 번째 옵션을 선택해 주세요!</option>";

                    for (var i = 0; i < rtn.length; i++) {
                        html += "<option value='"+ rtn[i].option +"'>" + rtn[i].option + "</option>";
                    }

                    jQuery("#option2").append(html);
                }
            });
        });
    });

</script>

<body>

<div class="wrap">
    <div class="pre-popup" id="prelaunching-start" style="display: none;">

        <div class="pre-body">
            <!-- div 사이에 제목 입력 -->
            <div onclick="closeModal('first')" class="closeModalButton">
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">
                    <g id="그룹_1143" data-name="그룹 1143" transform="translate(-1185 -325)">
                        <rect id="사각형_8917" data-name="사각형 8917" width="32" height="32" transform="translate(1185 325)" fill="none"/>
                        <path id="Icon_material-close" data-name="Icon material-close" d="M19.5,8.709,18.291,7.5,13.5,12.291,8.709,7.5,7.5,8.709,12.291,13.5,7.5,18.291,8.709,19.5,13.5,14.709,18.291,19.5,19.5,18.291,14.709,13.5Z" transform="translate(1187.5 327.5)" fill="#292929"/>
                    </g>
                </svg>
            </div>
            <div class="title" id="title1"></div>


            <div id="input_area">
                <div>
                    <div class="label label_margin">전화번호*</div>
                    <input class="input" id="userPhone" placeholder="- 없이 입력">
                </div>

                <div class="input-term label_margin">
                    <div class="label">E-mail*</div>
                    <input class="input" id="userMail" placeholder="id@email.com">
                </div>
            </div>

            <div id="check-area">
                <div style="height: 17px; display: inline-flex;">
                    <input type="checkbox" id="marketingFlag" style="display: none; float: left;" checked>
                    <svg class="checkbox" xmlns="http://www.w3.org/2000/svg" width="17" height="17" viewBox="0 0 17 17" id="marketing_checked" style="float: left;" onclick="checkbox_change('marketingChk')">
                        <g id="그룹_1134" data-name="그룹 1134" transform="translate(-726 -864)">
                            <g id="사각형_33" data-name="사각형 33" transform="translate(726 864)" fill="#fff" stroke="#d8d8d8" stroke-width="1">
                                <rect width="17" height="17" rx="2" stroke="none"/>
                                <rect x="0.5" y="0.5" width="16" height="16" rx="1.5" fill="none"/>
                            </g>
                            <path id="패스_18959" data-name="패스 18959" d="M4734.972,130.48l3.9,3.664,5.552-6.1" transform="translate(-4004.968 741.905)" fill="none" stroke="#292929" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                        </g>
                    </svg>
                    <svg class="checkbox" xmlns="http://www.w3.org/2000/svg" width="17" height="17" viewBox="0 0 17 17" id="marketing_no_check" style="display: none; float: left;" onclick="checkbox_change('marketingNoChk')">
                        <g id="사각형_33" data-name="사각형 33" fill="#fff" stroke="#d8d8d8" stroke-width="1">
                            <rect width="17" height="17" rx="2" stroke="none"/>
                            <rect x="0.5" y="0.5" width="16" height="16" rx="1.5" fill="none"/>
                        </g>
                    </svg>
                    <label style="cursor: pointer;" class="flag-label" for="marketingFlag" onclick="openApprovalModal()">마케팅 활용 동의(필수)</label>
                </div>

                <div>
                    <div style="margin-top: 9px; height: 17px; display: inline-flex;">
                        <input type="checkbox" id="prelaunchingFlag" style="display: none;">
                        <div class="check_area" id="pre_no_check" onclick="checkbox_change('preChk')" style="display: none; cursor: pointer;">
                            <svg class="checkbox" xmlns="http://www.w3.org/2000/svg" width="17" height="17" viewBox="0 0 17 17"  style="float: left;" >
                                <g id="사각형_33" data-name="사각형 33" fill="#fff" stroke="#d8d8d8" stroke-width="1">
                                    <rect width="17" height="17" rx="2" stroke="none"/>
                                    <rect x="0.5" y="0.5" width="16" height="16" rx="1.5" fill="none"/>
                                </g>
                            </svg>

                        </div>

                        <div class="check_area" id="pre_checked" onclick="checkbox_change('preNochk')" style="display: none; cursor: pointer;">
                            <svg class="checkbox" xmlns="http://www.w3.org/2000/svg" width="17" height="17" viewBox="0 0 17 17" style="float: left;" >
                                <g id="그룹_1134" data-name="그룹 1134" transform="translate(-726 -864)">
                                    <g id="사각형_33" data-name="사각형 33" transform="translate(726 864)" fill="#fff" stroke="#d8d8d8" stroke-width="1">
                                        <rect width="17" height="17" rx="2" stroke="none"/>
                                        <rect x="0.5" y="0.5" width="16" height="16" rx="1.5" fill="none"/>
                                    </g>
                                    <path id="패스_18959" data-name="패스 18959" d="M4734.972,130.48l3.9,3.664,5.552-6.1" transform="translate(-4004.968 741.905)" fill="none" stroke="#292929" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                                </g>
                            </svg>

                        </div>

                        <div onclick="openQuestionMark()" style="cursor: pointer !important; margin-top: -7px; margin-left: 1px;">
                            <label class="flag-label" for="prelaunchingFlag" style="cursor: pointer;">프리런칭 구독신청 (선택)</label>
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16">
                                <g id="그룹_67" data-name="그룹 67" transform="translate(-738 -319)">
                                    <path id="타원_7" data-name="타원 7" d="M8,2a6,6,0,1,0,6,6A6.007,6.007,0,0,0,8,2M8,0A8,8,0,1,1,0,8,8,8,0,0,1,8,0Z" transform="translate(738 319)" fill="#292929"/>
                                    <path id="패스_4763" data-name="패스 4763" d="M-.88-2.772H.528C.363-4.323,2.277-4.851,2.277-6.413A2.021,2.021,0,0,0-.011-8.5a3.043,3.043,0,0,0-2.31,1.1l.891.814A1.7,1.7,0,0,1-.209-7.205a.858.858,0,0,1,.935.9C.726-5.247-1.144-4.543-.88-2.772Zm.7,2.926A1.013,1.013,0,0,0,.836-.9,1.013,1.013,0,0,0-.176-1.958a1.011,1.011,0,0,0-1,1.056A1.011,1.011,0,0,0-.176.154Z" transform="translate(746 331)" fill="#292929"/>
                                </g>
                            </svg>
                        </div>


                    </div>
                </div>

            </div>

            <div style="margin-top: 15px; padding-top: 15px; padding-left: 32px; padding-right: 32px;">
                <button class="button" onclick="openSecondPopup()">프리런칭 신청하기</button>
            </div>

            <div style="margin-top: 9px; padding-left: 32px; padding-right: 32px; padding-bottom: 45px; width: 100%; text-align: center;">
                <span id="prelaunchingQna" onclick="openQna()">프리런칭이란?</span>
            </div>
        </div>
    </div>

    <div class='wrap1'>
        <div class="second_popup" id="qna_popup" style="display: none;">
            <div class="second_title">프리런칭 구독을 신청하시면?</div>

            <div class="second_text">키크론 신규 프리런칭 상품 정보, 예약 구매 소식과<br>예약 구매 시 다양한 혜택을 받아 볼 수 있습니다.</div>

            <div class="second_button">
                <button class="close_button" onclick="closeQuestionMark('close')" style="color: black">이번 프리런칭만 할래요</button>
                <button class="auto_prelaunching_button" onclick="closeQuestionMark('approval')">프리런칭 구독하기</button>
            </div>
        </div>
    </div>

    <div class='wrap2'>
        <div class="second_popup" id="second_popup" style="display: none;">
            <div class="second_title">프리런칭 구독신청하고<br>특별 혜택을 받아보세요.</div>

            <div class="second_text">프리런칭 구독을 신청하시고, 신규 프리런칭 상품 정보<br>예약 구매 소식과 예약 구매시 추가 사은품 등<br>프리런칭 구독자만의 특별 혜택을 받아보세요.</div>

            <div class="second_button">
                <button class="close_button" onclick="closeSecondPopup('close')">다음에 할게요</button>
                <button class="auto_prelaunching_button" onclick="closeSecondPopup('approval')">무료로 받아보기</button>
            </div>
        </div>
    </div>

    <div class="wrap4">
        <div class="second_popup" id="third_popup" style="display: none;">
            <div class="second_title">프리런칭이란?</div>

            <div class="second_text">프리런칭을 신청하시면 출시를 앞둔 신제품의 발매 소식과<br>특별 구매 혜택을 가장 빠르게 받아볼 수 있습니다.</div>

            <div class="third_button">
                <button class="question_button" onclick="closeQna()">확인</button>
            </div>
        </div>
    </div>


    <div class="pre-popup" id="prelaunching-option" style="display: none;">
        <div class="pre-body">
            <!-- div 사이에 제목 입력 -->
            <div onclick="closeModal('second')" class="closeModalButton">
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">
                    <g id="그룹_1143" data-name="그룹 1143" transform="translate(-1185 -325)">
                        <rect id="사각형_8917" data-name="사각형 8917" width="32" height="32" transform="translate(1185 325)" fill="none"/>
                        <path id="Icon_material-close" data-name="Icon material-close" d="M19.5,8.709,18.291,7.5,13.5,12.291,8.709,7.5,7.5,8.709,12.291,13.5,7.5,18.291,8.709,19.5,13.5,14.709,18.291,19.5,19.5,18.291,14.709,13.5Z" transform="translate(1187.5 327.5)" fill="#292929"/>
                    </g>
                </svg>
            </div>
            <div class="title" id="title2"></div>


            <div id="input_area2">
                <div>
                    <div class="label label_margin">옵션1</div>
                    <select class="input select2" id="option1"></select>
                </div>

                <div class="input-term label_margin" style="height: 84px;">
                    <div class="label option22">옵션2</div>
                    <select class="input select2 option22" id="option2">
                        <option value='' >두 번째 옵션을 선택해 주세요!</option>
                    </select>
                </div>
            </div>

            <div style="margin-top: 42px; padding-top: 15px; padding-left: 32px; padding-right: 32px; padding-bottom: 83px;">
                <button class="button" onclick="closeOptionPopup()">옵션 선택 완료</button>
            </div>
        </div>
    </div>


    <div class="end_popup" id="prelaunching-end" style="display: none;">

        <div id="end_title">프리런칭 신청 완료!</div>
        <div id="end_label">등록하신 정보로 신제품 관련 소식을 보내드립니다.</div>

        <div id="end_info_area">
            <div id="end_info" style="height: 226px;">
                <div class="info_turm" id="end_phone" >
                    <div class="info_left">전화번호</div>
                    <div class="info_right" id="phone">010-1111-1111</div>
                </div>

                <div class="info_turm" id="end_mail">
                    <div class="info_left">E-mail</div>
                    <div class="info_right" id="email">id@email.com</div>
                </div>

                <div class="info_turm" id="end_pre_flag">
                    <div class="info_left">프리런칭 자동참여</div>
                    <div class="info_right" id="preFlag">미참여</div>
                </div>

                <div class="info_turm" id="end_pre_option1">
                    <div class="info_left">옵션1</div>
                    <div class="info_right" id="preOption1"></div>
                </div>

                <div class="info_turm option22" id="end_pre_option2">
                    <div class="info_left">옵션2</div>
                    <div class="info_right" id="preOption2"></div>
                </div>
            </div>
        </div>


        <div style="margin-top: 60px; margin-left: 32px; margin-right: 32px; padding-bottom: 40px;">
            <button class="button" onclick="closeModal('last')">확인</button>
        </div>
    </div>

    <div class="wrap3">
        <div id="showTerms" style="display: none;">
            <div id="termsHeader">
                <h4 id="termsTitle">마케팅활용동의</h4>
                <div onclick="closeTerms()" id="termsClose">
                    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">
                        <g id="그룹_1143" data-name="그룹 1143" transform="translate(-1185 -325)">
                            <rect id="사각형_8917" data-name="사각형 8917" width="32" height="32" transform="translate(1185 325)" fill="none"/>
                            <path id="Icon_material-close" data-name="Icon material-close" d="M19.5,8.709,18.291,7.5,13.5,12.291,8.709,7.5,7.5,8.709,12.291,13.5,7.5,18.291,8.709,19.5,13.5,14.709,18.291,19.5,19.5,18.291,14.709,13.5Z" transform="translate(1187.5 327.5)" fill="#292929"/>
                        </g>
                    </svg>
                </div>
            </div>
            <div id="termsBody">

            </div>
            <div id="termsBottom">
                <button data-bb-handler="alert" type="button" class="btn btn-primary" onclick="closeTerms()">확인</button>
            </div>
        </div>
    </div>

</div>

</body>

<style>
    .wrap {
        z-index: 9999;
    }

    .clear {
        display: block !important;
    }

    .shadow {
        position: fixed;
        top:0; left: 0; bottom: 0; right: 0;
        background: rgba(0, 0, 0, 0.5);
    }

    .pre-popup {
        width: 532px;
        background: #FFFFFF 0% 0% no-repeat padding-box;
        box-shadow: 0px 3px 6px #00000029;
        margin: 0 auto;
        transform: translateY(-50%);
        position: relative;
        top: 50%;
        opacity: 1;
    }

    .pre-body {
        width: 532px;
        /* UI Properties */
        background: #FFFFFF 0% 0% no-repeat padding-box;
        box-shadow: 0px 3px 6px #00000029;
        opacity: 1;
    }

    .closeModalButton {
        float: right;
        cursor: pointer;
    }

    #title1 {
        padding-top: 32px;
        padding-left: 32px;
        text-align: left;
        font: normal normal bold 26px/38px Noto Sans CJK KR, Apple SD Gothic Neo  !important;
        letter-spacing: -1.04px;
        color: #292929;
        opacity: 1;
    }

    #title2 {
        padding-top: 32px;
        padding-left: 32px;
        text-align: left;
        font: normal normal bold 26px/38px Noto Sans CJK KR, Apple SD Gothic Neo  !important;
        letter-spacing: -1.04px;
        color: #292929;
        opacity: 1;
    }

    #input_area {
        padding-top: 38px;
        padding-left: 32px;
        padding-right: 32px;
    }

    #input_area2 {
        padding-top: 38px;
        padding-left: 32px;
        padding-right: 32px;
        padding-bottom: 43px;
    }

    .label {
        text-align: left;
        font: normal normal 500 14px/20px Noto Sans CJK KR, Apple SD Gothic Neo  !important;
        letter-spacing: 0px;
        color: #292929;
        opacity: 1;
    }

    .label_margin {
        margin-top: 24px;
    }

    .input {
        margin-top: 8px !important;
        width: 100% !important;
        height: 46px !important;
        /* UI Properties */
        border: 1px solid #B5B5B5 !important;
        border-radius: 5px !important;
        opacity: 1 !important;
        padding: 8px !important;
        background-color: white;
    }

    #input_area > div > input:focus {
        outline: 0;
        border: 2px solid black !important;
    }

    #check-area {
        padding-top: 19px;
        padding-left: 32px;
    }

    .checkbox {
        cursor: pointer;
    }

    .flag-label {
        margin-left: 5px;
        text-align: left;
        font: normal normal 500 14px/20px Noto Sans CJK KR, Apple SD Gothic Neo !important;
        letter-spacing: 0px;
        color: #292929;
        opacity: 1;
    }

    #prelaunchingQna {
        text-align: center;
        font: normal normal 500 13px/20px Noto Sans CJK KR, Apple SD Gothic Neo !important;
        letter-spacing: 0px;
        color: #292929;
        opacity: 1;
        text-decoration: underline;
        cursor: pointer;
    }

    .button {
        width: 100% !important;
        background: #292929 0% 0% no-repeat padding-box !important;
        border-radius: 5px !important;
        opacity: 1 !important;
        cursor: pointer !important;
    }

    .button :hover {
        width: 100% !important;
        background: #292929 0% 0% no-repeat padding-box !important;
        border-radius: 5px !important;
        opacity: 1 !important;
        cursor: pointer !important;
    }

    .second_popup {
        width: 496px;
        border: 1px solid;
        opacity: 1;
        border-radius: 24px;
        z-index: 9999;
        background: #FFFFFF 0% 0% no-repeat padding-box;
        margin: 0 auto;
        position: relative;
        top: 42% !important;
        transform: translateY(-50%);
    }

    .second_title {
        margin-top: 46px;
        text-align: center;
        font: normal normal bold 26px/35px Pretendard;
        letter-spacing: -1.04px;
        color: #000000;
        opacity: 1;
    }

    .second_text {
        margin-top: 14px;
        text-align: center;
        font: normal normal normal 16px/26px Pretendard Noto Sans CJK KR, Apple SD Gothic Neo !important;
        letter-spacing: -0.64px;
        color: #000000;
        opacity: 1;
    }

    .second_button {
        margin-top: 39px;
        margin-left: 34px;
        margin-right: 34px;
        margin-bottom: 38px;
        height: 48px;
    }

    .third_button {
        margin-top: 39px;
        margin-bottom: 38px;
        height: 48px;
    }

    .close_button {
        border: 1px solid #B5B5B5;
        border-radius: 5px;
        opacity: 1;
        background-color: #FFFFFF;
        height: 48px;
        width: 48%;
    }

    .auto_prelaunching_button {
        border: 1px solid #B5B5B5;
        border-radius: 5px;
        opacity: 1;
        background: #292929 0% 0% no-repeat padding-box;
        height: 48px;
        width: 48%;
        float: right;
        color: #FFFFFF;
    }

    .question_button {
        border: 1px solid #B5B5B5;
        border-radius: 5px;
        opacity: 1;
        background: #292929 0% 0% no-repeat padding-box;
        height: 48px;
        width: 48%;
        color: #FFFFFF;
        display: block;
        margin: auto;
    }

    .end_popup {
        width: 532px;
        background: #FFFFFF 0% 0% no-repeat padding-box;
        box-shadow: 0px 3px 6px #00000029;
        margin: 0 auto;
        transform: translateY(-50%);
        position: relative;
        top: 50%;
        opacity: 1;
    }

    #end_title {
        font: normal normal bold 26px/38px Noto Sans CJK KR, Apple SD Gothic Neo !important;
        letter-spacing: -1.04px;
        color: #292929;
        opacity: 1;
        text-align: center;
        padding-top: 32px;
    }

    #end_label {
        margin-top: 4px;
        text-align: center;
        font: normal normal normal 16px/24px Noto Sans CJK KR, Apple SD Gothic Neo !important;
        letter-spacing: -0.64px;
        color: #292929;
        opacity: 1;
    }

    #end_info_area {
        padding-top: 36px;
        padding-right: 32px;
        padding-left: 32px;
    }

    #end_info {
        width: 100%;
        border: 1px solid #BEBEBE;
        border-radius: 24px;
        opacity: 1;
        padding-left: 50px;
        padding-right: 50px;

    }

    #end_phone {
        margin-top: 40px;
    }

    #end_pre_option2 {
        margin-bottom: 36px;
    }

    .info_turm {
        margin-top: 12px;
    }

    .info_left {
        float: left;
        font: normal normal 500 14px/20px Noto Sans CJK KR, Apple SD Gothic Neo !important;
        letter-spacing: 0px;
        color: #5D5D5D;
        opacity: 1;
    }

    .info_right {
        text-align: left;
        font: normal normal normal 14px/20px Noto Sans CJK KR, Apple SD Gothic Neo !important;
        letter-spacing: 0px;
        color: #292929;
        opacity: 1;
        margin-left: 47%;
    }

    .wrap3 {
        z-index: 999;
        overflow: auto;
    }

    #showTerms {
        width: 50%;
        border: 1px solid;
        opacity: 1;
        z-index: 99999;
        background: #FFFFFF 0% 0% no-repeat padding-box;
        margin: 0 auto;
        position: relative;
        top: 10% !important;
        margin-bottom: 10%;
    }

    #termsHeader {
        width: 100%;
        padding-left: 2%;
        height: 60px;
        border-bottom: 1px solid #dee2e6;
    }

    #termsTitle {
        float: left;
        margin-bottom: 0;
        line-height: 2.5;
    }

    #termsClose {
        float: right;
        cursor: pointer;
        opacity: .75;
        padding: 10px;
    }

    .btn-primary {
        color: #fff;
        background-color: #007bff;
        border-color: #007bff;
        cursor: pointer;
        float: right;
        margin-right: 20px;
        margin-top: 10px;
    }

    #termsBody {
        padding-right: 2%;
        padding-left: 2%;
        padding-bottom: 2%;
        padding-top: 1%;
    }

    #termsBottom {
        border-top: 1px solid #dee2e6;
        height: 60px;
    }

    .check_area > label {
        float: right;
        cursor: pointer;
        line-height: 17px !important;
    }

    select option[value=""][disabled] {
        display: none;
    }

    @media (max-width: 768px) {
        .wrap {
            z-index: 9999;
        }

        .clear {
            display: block !important;
        }

        .shadow {
            position: fixed;
            top:0; left: 0; bottom: 0; right: 0;
            background: rgba(0, 0, 0, 0.5);
        }

        .pre-popup {
            width: 100%;
            background: #FFFFFF 0% 0% no-repeat padding-box;
            box-shadow: 0px 3px 6px #00000029;
            margin: 0 auto;
            transform: translateY(-50%);
            position: relative;
            top: 50%;
            opacity: 1;
        }

        .pre-body {
            width: 100%;
            /* UI Properties */
            background: #FFFFFF 0% 0% no-repeat padding-box;
            box-shadow: 0px 3px 6px #00000029;
            opacity: 1;
            margin: 0px auto;
        }

        .closeModalButton {
            float: right;
            cursor: pointer;
        }

        #title1 {
            padding-top: 32px;
            padding-left: 32px;
            text-align: left;
            font: normal normal bold 26px/38px Noto Sans CJK KR, Apple SD Gothic Neo !important;
            letter-spacing: -1.04px;
            color: #292929;
            opacity: 1;
        }

        #title2 {
            padding-top: 32px;
            padding-left: 32px;
            text-align: left;
            font: normal normal bold 26px/38px Noto Sans CJK KR, Apple SD Gothic Neo !important;
            letter-spacing: -1.04px;
            color: #292929;
            opacity: 1;
        }

        #input_area {
            padding-top: 38px;
            padding-left: 32px;
            padding-right: 32px;
        }

        .label {
            text-align: left;
            font: normal normal 500 14px/20px Noto Sans CJK KR, Apple SD Gothic Neo !important;
            letter-spacing: 0px;
            color: #292929;
            opacity: 1;
        }

        .label_margin {
            margin-top: 24px;
        }

        .input {
            margin-top: 8px !important;
            width: 100% !important;
            height: 46px !important;
            /* UI Properties */
            border: 1px solid #B5B5B5 !important;
            border-radius: 5px !important;
            opacity: 1 !important;
            padding: 8px !important;
            background-color: white;
        }

        #input_area > div > input:focus {
            outline: 0;
            border: 2px solid black !important;
        }

        #check-area {
            padding-top: 19px;
            padding-left: 32px;
        }

        .checkbox {
            cursor: pointer;
        }

        .flag-label {
            margin-left: 5px;
            text-align: left;
            font: normal normal 500 14px/20px Noto Sans CJK KR, Apple SD Gothic Neo !important;
            letter-spacing: 0px;
            color: #292929;
            opacity: 1;
        }

        #prelaunchingQna {
            text-align: center;
            font: normal normal 500 13px/20px Noto Sans CJK KR, Apple SD Gothic Neo !important;
            letter-spacing: 0px;
            color: #292929;
            opacity: 1;
            text-decoration: underline;
            cursor: pointer;
        }

        .button {
            width: 100% !important;
            background: #292929 0% 0% no-repeat padding-box !important;
            border-radius: 5px !important;
            opacity: 1 !important;
            cursor: pointer !important;
        }

        .button :hover {
            width: 100% !important;
            background: #292929 0% 0% no-repeat padding-box !important;
            border-radius: 5px !important;
            opacity: 1 !important;
            cursor: pointer !important;
        }

        .second_popup {
            width: 100%;
            border: 1px solid;
            opacity: 1;
            border-radius: 24px;
            z-index: 99999;
            background: #FFFFFF 0% 0% no-repeat padding-box;
            margin: 0 auto;
            position: relative;
            top: 42% !important;
            transform: translateY(-50%);
        }

        .third_popup {
            width: 100%;
            border: 1px solid;
            opacity: 1;
            border-radius: 24px;
            z-index: 99999;
            background: #FFFFFF 0% 0% no-repeat padding-box;
            margin: 0 auto;
            position: relative;
            top: 42% !important;
            transform: translateY(-50%);
        }

        .second_title {
            margin-top: 46px;
            text-align: center;
            font: normal normal bold 26px/35px Pretendard Noto Sans CJK KR, Apple SD Gothic Neo !important;
            letter-spacing: -1.04px;
            color: #000000;
            opacity: 1;
        }

        .second_text {
            margin-top: 14px;
            text-align: center;
            font: normal normal normal 16px/26px Pretendard Noto Sans CJK KR, Apple SD Gothic Neo !important;
            letter-spacing: -0.64px;
            color: #000000;
            opacity: 1;
        }

        .second_button {
            margin-top: 39px;
            margin-left: 34px;
            margin-right: 34px;
            margin-bottom: 38px;
            height: 48px;
        }

        .third_button {
            margin-top: 39px;
            margin-bottom: 38px;
            height: 48px;
        }

        .close_button {
            border: 1px solid #B5B5B5;
            border-radius: 5px;
            opacity: 1;
            background-color: #FFFFFF;
            height: 48px;
            width: 48%;
        }

        .auto_prelaunching_button {
            border: 1px solid #B5B5B5;
            border-radius: 5px;
            opacity: 1;
            background: #292929 0% 0% no-repeat padding-box;
            height: 48px;
            width: 48%;
            float: right;
            color: #FFFFFF;
        }

        .question_button {
            border: 1px solid #B5B5B5;
            border-radius: 5px;
            opacity: 1;
            background: #292929 0% 0% no-repeat padding-box;
            height: 48px;
            width: 48%;
            color: #FFFFFF;
            display: block;
            margin: auto;
        }

        .end_popup {
            width: 100%;
            background: #FFFFFF 0% 0% no-repeat padding-box;
            box-shadow: 0px 3px 6px #00000029;
            margin: 0 auto;
            transform: translateY(-50%);
            position: relative;
            top: 50%;
            opacity: 1;
        }

        #end_title {
            font: normal normal bold 26px/38px Noto Sans CJK KR, Apple SD Gothic Neo !important;
            letter-spacing: -1.04px;
            color: #292929;
            opacity: 1;
            text-align: center;
            padding-top: 32px;
        }

        #end_label {
            margin-top: 4px;
            text-align: center;
            font: normal normal normal 16px/24px Noto Sans CJK KR, Apple SD Gothic Neo !important;
            letter-spacing: -0.64px;
            color: #292929;
            opacity: 1;
        }

        #end_info_area {
            padding-top: 36px;
            padding-right: 32px;
            padding-left: 32px;
        }

        #end_info {
            width: 100%;
            border: 1px solid #BEBEBE;
            border-radius: 24px;
            opacity: 1;
            padding-right: 5%;
            padding-left: 5%;

        }

        #end_name {
            margin-top: 40px;
        }

        #end_pre_option2 {
            margin-bottom: 36px;
        }

        .info_turm {
            margin-top: 12px;
        }

        .info_left {
            float: left;
            font: normal normal 500 14px/20px Noto Sans CJK KR, Apple SD Gothic Neo  !important;
            letter-spacing: 0px;
            color: #5D5D5D;
            opacity: 1;
            margin-left: 5%;
        }

        .info_right {
            text-align: left;
            font: normal normal normal 14px/20px Noto Sans CJK KR, Apple SD Gothic Neo  !important;
            letter-spacing: 0px;
            color: #292929;
            opacity: 1;
            margin-left: 50%;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .wrap3 {
            z-index: 999;
            overflow: auto;
        }

        #showTerms {
            width: 100%;
            border: 1px solid;
            opacity: 1;
            z-index: 99999;
            background: #FFFFFF 0% 0% no-repeat padding-box;
            margin: 0 auto;
            position: relative;
            top: 10% !important;
            margin-bottom: 10%;
        }

        #termsHeader {
            width: 100%;
            padding-left: 2%;
            height: 60px;
            border-bottom: 1px solid #dee2e6;
        }

        #termsTitle {
            float: left;
            margin-bottom: 0;
            line-height: 2.5;
        }

        #termsClose {
            float: right;
            cursor: pointer;
            opacity: .75;
            padding: 10px;
        }

        .btn-primary {
            color: #fff;
            background-color: #007bff;
            border-color: #007bff;
            cursor: pointer;
            float: right;
            margin-right: 20px;
            margin-top: 10px;
        }

        #termsBody {
            padding-right: 2%;
            padding-left: 2%;
            padding-bottom: 2%;
            padding-top: 1%;
        }

        #termsBottom {
            border-top: 1px solid #dee2e6;
            height: 60px;
        }

        .check_area > label {
            float: right;
            cursor: pointer;
            line-height: 17px !important;
        }
    }
</style>
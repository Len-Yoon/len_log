<script>
    var giveawayhome;
    var endDateTime = [];
    var startDateTime = [];

    function setDateTimer(endDateTime, startDateTime) {

        for (var i = 0; i < endDateTime.length; i++) {
            var reEndDateTime = endDateTime[i].replace(/-/gi, "/")
            var reStartDateTime = startDateTime[i].replace(/-/gi, "/")
            var nowTime = new Date();
            var endTime = new Date(reEndDateTime)
            var startTime = new Date(reStartDateTime)
            var diff;
            if(nowTime > startTime) {
                diff = endTime - nowTime;
            } else {
                diff = startTime - nowTime;
            }

            var diffHour = Math.floor(diff / (1000*60*60));
            var diffMin = Math.floor(diff / (1000*60) % 60);
            var diffSec = Math.floor(diff / 1000 % 60);

            if (diffHour < 10 && diffHour >= 0) {diffHour = "0" + diffHour;}
            if (diffMin < 10 && diffMin >= 0) {diffMin = "0" + diffMin;}
            if (diffSec < 10 && diffSec >= 0) {diffSec = "0"+diffSec}
            var diffText = diffHour+ ":" + diffMin + ":" + diffSec;

            if(diffHour < 0) {
                jQuery("#timer" + i).text('00:00:00');
            } else {
                jQuery("#timer" + i).text(diffText);
            }
        }
    }

    function allList() {
        for (var i = 5; i < giveawayhome.length; i++) {
            addGiveawayInfo(i);
        }
        jQuery(".add_button").removeClass('block')
    }

    function addGiveawayInfo(i) {
        var now = new Date();

        endDateTime[i] = giveawayhome[i].endDateTime;
        startDateTime[i] = giveawayhome[i].startDateTime;

        var html = "";
        html += "<li style='width: 100%;'>";
        html += '<div class="list_img" style="width: 50%; float: left;">';
        html += "<a>";
        html += '<img src= "' + giveawayhome[i].homeLink + '">';
        html += "</a>";
        html += "</div>";
        html += "<div class='list_info' style='width: 47%; margin-top: 5%; float: right;'>";
        html += "<div class='list_text'>"
        html += "<a>";
        html += "<h3>" + giveawayhome[i].homeMain + "</h3>";
        html += "</a>";
        html += "<p>";
        html += '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 14 14">';
        html += '<g id="그룹_1106" data-name="그룹 1106" transform="translate(-140 -407)">';
        html += '<g id="타원_126" data-name="타원 126" transform="translate(140 407)" fill="none" stroke="#404040" stroke-width="1">';
        html += '<circle cx="7" cy="7" r="7" stroke="none"/>';
        html += '<circle cx="7" cy="7" r="6.5" fill="none"/>';
        html += '</g>';
        html += '<path id="패스_28236" data-name="패스 28236" d="M2014.688,457l-2.745,2.745v2.645" transform="translate(-1864.943 -45.695)" fill="none" stroke="#404040" stroke-linecap="round" stroke-width="1"/>';
        html += '</g>';
        html += '</svg>';
        html += giveawayhome[i].startDate + " ~ " + giveawayhome[i].endDate
        html += "</p>";
        html += "<p>";
        html += "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"12\" height=\"12\" viewBox=\"0 0 12 12\">";
        html += "<g id=\"Icon_feather-user\" data-name=\"Icon feather-user\" transform=\"translate(-5 -4)\">";
        html += "<path id=\"패스_28234\" data-name=\"패스 28234\" d=\"M16.991,26.67a.5.5,0,0,1-.509-.5V24.947A1.967,1.967,0,0,0,14.5,23h-6a1.967,1.967,0,0,0-1.982,1.947V26.17a.509.509,0,0,1-1.018,0V24.947A2.977,2.977,0,0,1,8.5,22h6a2.977,2.977,0,0,1,3,2.947V26.17A.5.5,0,0,1,16.991,26.67Z\" transform=\"translate(-0.5 -10.67)\" fill=\"#404040\"/>";
        html += '<path id="패스_28235" data-name="패스 28235" d="M14.553,4a3,3,0,0,1,3.053,2.947,3.055,3.055,0,0,1-6.106,0A3,3,0,0,1,14.553,4Zm0,4.894A1.985,1.985,0,0,0,16.57,6.947a2.018,2.018,0,0,0-4.034,0A1.985,1.985,0,0,0,14.553,8.894Z" transform="translate(-3.553 0)" fill="#404040"/>';
        html += "</g>";
        html += "</svg>";
        html += "<div>" + giveawayhome[i].count + "명 참여" + "</div>";
        html += "</p>";
        html += '</div>';
        html += "<p id='timer" + i + "' ";
        if (giveawayhome[i].timeFlag == "ing") {
            html += "class='timer timer_ing'";
        } else {
            html += "class='timer'";
        }
        html += "style='color: #7D7D7D; line-height: 100%; font-weight: normal; vertical-align: text-top; font-size: 120px;'></p>"
        html += '<div class="gt_giveaway_footer">';
        if (giveawayhome[i].timeFlag == "ready") {
            html += '<div class="next_button">';
            html += '<a>';
            html += '<h3 id="button_text">COMING SOON</h3>';
            html += '</a>';
        } else if (giveawayhome[i].timeFlag == "ing") {
            html += '<div class="next_button activation">';
            html += '<a href="https://keychron.kr/giveaway?object=' + giveawayhome[i].object + '">';

            html += '<h3 id="button_text">응모하기</h3>';
            html += '</a>';
        } else {
            if (new Date(giveawayhome[i].rewardDate.replace(/-/gi, "/")) > now) {
                html += '<div class="next_button">';
                html += '<a>';
                html += '<h3 id="button_text" style="color: #ffffff; background-color: #000000; border-radius: 12px;">당첨자 발표 예정</h3>';
                html += '</a>';
            } else {
                html += '<div class="next_button">';
                html += '<a href=" https://keychron.kr/keychron_giveaway_result/?object='+ giveawayhome[i].object + '">';
                html += '<h3 id="button_text" style="color: #ffffff; background-color: #000000; border-radius: 12px;">당첨 결과 확인하기</h3>';
                html += '</a>';
            }

        }
        html += "</div>";

        html += '<div class="info_button">';
        html += '<a href="' + giveawayhome[i].rewardLink +'" target="_blank">';
        html += '<h3 id="button_text" style="margin-top: -2px;">제품정보 보기</h3>';
        html += '</a>';
        html += '</div>';

        html += '</div>';
        html += "</li>";

        jQuery("#giveawayList").append(html);

        setInterval(function() { setDateTimer(endDateTime, startDateTime) },1000);
    }

    jQuery(document).ready(function () {
        var urlParams = new URL(location.href).searchParams;

        var num = urlParams.get('num');

        jQuery.ajax({
            url: "/event/selectGiveawayhome",
            type: 'GET',
            dataType: 'json',
            data: {
                giveawayType: 'keychron'
            },
            success: function (giveawayHome) {
                giveawayhome = giveawayHome;
                var length = giveawayHome.length;

                if (giveawayHome.length > 5) {
                    jQuery(".add_button").addClass('block')
                    length = 5;
                }

                for (var i = 0; i < length; i++) {
                    addGiveawayInfo(i);
                }

                if (num != null) {
                    if(num > 4) {
                        allList();
                    }

                    setTimeout(function() {
                        var offset = jQuery("#giveawayList > li:eq(" + num + ") > div").offset();
                        jQuery("html, body").animate({scrollTop: offset.top},400);
                    }, 1200);
                }
            }
        });
    });
</script>

<body>
<div class="page-body">
    <div class="intro">
        <h1>
            <svg xmlns="http://www.w3.org/2000/svg" width="196.02" height="26.064" viewBox="0 0 196.02 26.064">
                <path id="패스_30465" data-name="패스 30465" d="M20.016-13h5.328V-2.772A15.222,15.222,0,0,1,20.592-.4a18.449,18.449,0,0,1-5.436.828A14.731,14.731,0,0,1,8.1-1.242,12.461,12.461,0,0,1,3.186-5.886,12.8,12.8,0,0,1,1.4-12.6a12.8,12.8,0,0,1,1.782-6.714,12.4,12.4,0,0,1,4.95-4.644,15.02,15.02,0,0,1,7.128-1.674,15.6,15.6,0,0,1,6.012,1.116,11.912,11.912,0,0,1,4.536,3.24L22.068-17.82a8.659,8.659,0,0,0-6.516-2.844,8.894,8.894,0,0,0-4.284,1.008,7.231,7.231,0,0,0-2.916,2.844A8.371,8.371,0,0,0,7.308-12.6,8.3,8.3,0,0,0,8.352-8.424a7.384,7.384,0,0,0,2.9,2.862,8.589,8.589,0,0,0,4.23,1.026,9.452,9.452,0,0,0,4.536-1.08ZM29.3-25.2h5.832V0H29.3Zm34.452,0L52.848,0h-5.76L36.216-25.2h6.3l7.668,18,7.776-18ZM83.916-4.68V0H64.4V-25.2H83.448v4.68H70.2v5.472H81.9v4.536H70.2V-4.68Zm19.8-.72h-11.7L89.784,0H83.808L95.04-25.2h5.76L112.068,0h-6.12ZM101.88-9.828l-4-9.648-4,9.648Zm48.1-15.372L141.732,0h-6.264l-5.544-17.064L124.2,0h-6.228l-8.28-25.2h6.048l5.688,17.712,5.94-17.712h5.4l5.76,17.856L144.4-25.2ZM167.544-5.4h-11.7L153.612,0h-5.976l11.232-25.2h5.76L175.9,0h-6.12Zm-1.836-4.428-4-9.648-4,9.648Zm21.924.9V0H181.8V-9l-9.756-16.2h6.192L184.968-14,191.7-25.2h5.724Z" transform="translate(-1.404 25.632)" fill="#292929"/>
            </svg>
        </h1>
        <p>지금 바로 행운의 기회를 잡아보세요.</p>
        <span></span>
        <ul class="giveaway_banner" id="giveawayList">

        </ul>
        <div class="add_button" onClick="allList();" style="display: none; margin-bottom: 50px;">더보기</div>
    </div>

    <div id="footer_text" style="padding: 5% 0; background-color: #383838;">
        <div style=" ">안내사항</div>
        <pre style="">
- 추첨 결과는 기브어웨이 페이지에 게재됩니다.
- 미션 미완료 시 당첨이 취소될 수 있습니다.
- 기브어웨이 당첨자에겐 개별 연락을 드립니다.
- 당사 사정에 따라 이벤트 내용이 변동될 수 있습니다.
        </pre>
    </div>
</div>
</body>
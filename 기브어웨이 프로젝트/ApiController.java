package com.tbnws.gtgear.support.controller;

import com.google.api.client.util.DateTime;
import com.google.api.services.calendar.model.*;
import com.tbnws.gtgear.support.Util.AuthCalendarUtil;
import com.tbnws.gtgear.support.Util.Utils;
import com.tbnws.gtgear.support.model.*;
import io.swagger.annotations.*;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.xml.sax.InputSource;
import springfox.documentation.annotations.ApiIgnore;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.*;
import java.util.concurrent.TimeUnit;

import static com.tbnws.gtgear.support.config.SwaggerConfig.RESPONSE_PREFIX;
import static java.time.temporal.ChronoUnit.DAYS;

@Api(tags = "ApiController", description = "공통 및 외부 API", basePath = "/")
@Controller
public class ApiController extends CommonController {

    private static Logger logger = LoggerFactory.getLogger(ApiController.class);

    @Value("${labor_union_line}")
    String LABOR_UNION_LINE;

    @Value("${chatgpt_secret_key}")
    String CHATGPT_SECRET_KEY;

    // 07E_API_URL
    @Value("${o7e_api_url}")
    String O7E_API_URL;

    @Value("${email_auth_address}")
    String EMAIL_AUTH_ADDRESS;

    @Value("${email_auth_password}")
    String EMAIL_AUTH_PASSWORD;

    @Value("${authorization_key}")
    String AUTHORIZATION_KEY; // encodeBase64(encryptSHA512("GTGEAR"))

    @Value("${order_calendar_id}")
    String ORDER_CALENDAR_ID;

    @Value("${notion_secret}")
    String NOTION_SECRET;

    @Value("${encrypt_key}")
    String ENCRYPT_KEY;

    @Value("${naver_shortenurl_id}")
    String NAVER_SHORTENURL_ID;

    @Value("${naver_shortenurl_secret}")
    String NAVER_SHORTENURL_SECRET;

    @Value("${data_service_key}")
    String DATA_SERVICE_KEY;

    @Value("${cafe24_tobeDev_clientID}")
    String CAFE24_TOBEDEV_ID;

    @Value("${cafe24_tobeDev_clientSecretKey}")
    String CAFE24_TOBEDEV_SECRET;

    @Value("${upload_path}")
    String UPLOAD_PATH;

    @Value("${ftp_path}")
    String FTP_PATH;


    @ApiOperation(value = "워드프레스 기브어웨이 날짜 체크 API", httpMethod = "GET", notes = Len.Yun)
    @RequestMapping(value = "/api/wpGiveawayDateCheck")
    public void wpGiveawayDateCheck(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/wpGiveawayDateCheck [" + getClass().getSimpleName() + ".wpGiveawayDateCheck()] start ======");
        int rtn = -1;
        try {
            String object = Utils.checkNull(request.getParameter("object"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /api/wpGiveawayDateCheck [" + getClass().getSimpleName() + ".wpGiveawayDateCheck()] object : " + object);

            rtn = supportService.selectGiveawayDateCheck(object);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/wpGiveawayDateCheck [" + getClass().getSimpleName() + ".wpGiveawayDateCheck()] end ======");
    }


    @ApiOperation(value = "워드프레스 기브어웨이 참여확인 API", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping(value = "/api/wpGiveawayCheck")
    public void wpGiveawayCheck(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/wpGiveawayCheck [" + getClass().getSimpleName() + ".wpGiveawayCheck()] start ======");
        int rtn = -1;
        try {
            String title = Utils.checkNull(request.getParameter("title"));
            String email = Utils.checkNull(request.getParameter("email"));
            String phone = Utils.checkNull(request.getParameter("phone").replaceAll("-", "").replaceAll(" ", ""));
            logger.info("[" + request.getRemoteAddr() + "] ====== /api/wpGiveawayCheck [" + getClass().getSimpleName() + ".wpGiveawayCheck()] title : " + title);
            logger.info("[" + request.getRemoteAddr() + "] ====== /api/wpGiveawayCheck [" + getClass().getSimpleName() + ".wpGiveawayCheck()] email : " + email);
            logger.info("[" + request.getRemoteAddr() + "] ====== /api/wpGiveawayCheck [" + getClass().getSimpleName() + ".wpGiveawayCheck()] phone : " + phone);

            rtn = supportService.selectGiveawayCheck(title, email, phone);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/wpGiveawayCheck [" + getClass().getSimpleName() + ".wpGiveawayCheck()] end ======");
    }

    @ApiOperation(value = "워드프레스 기브어웨이 이벤트용", notes = "Len.Yun")
    @RequestMapping(value = "/api/selectGiveaway")
    public void selectGiveaway(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/selectGiveaway [" + getClass().getSimpleName() + ".selectGiveaway()] start ======");
        try {
            String object = Utils.checkNull(request.getParameter("object"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /api/selectGiveaway [" + getClass().getSimpleName() + ".selectGiveaway()] object : " + object);

            EventVO giveawayInfo = eventService.selectGiveaway(object, new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new Date()).substring(0, 15));
            JSONObject json = new JSONObject();

            if (giveawayInfo != null) {
                json.put("giveawayTitle", Utils.checkNull(giveawayInfo.getGiveaway_title()));
                json.put("giveawayText", Utils.checkNull(giveawayInfo.getGiveaway_text()));
                json.put("startDate", new SimpleDateFormat("yyyy.MM.dd").format(giveawayInfo.getStart_date()));
                json.put("endDate", new SimpleDateFormat("yyyy.MM.dd").format(giveawayInfo.getEnd_date()));
                json.put("timerTime", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(giveawayInfo.getEnd_date()));
                json.put("successText", Utils.checkNull(giveawayInfo.getSuccess_text()));
                json.put("giveawaySeq", giveawayInfo.getGiveaway_seq());
                json.put("buttonFlag", Utils.checkNull(giveawayInfo.getButton_flag()));
                json.put("buttonText", Utils.checkNull(giveawayInfo.getButton_text()));
                json.put("buttonLink", Utils.checkNull(giveawayInfo.getButton_link()));
                json.put("homeSub", Utils.checkNull(giveawayInfo.getHome_sub()));
                json.put("homeMain", Utils.checkNull(giveawayInfo.getHome_main()));
                json.put("homeLink", Utils.checkNull(giveawayInfo.getHome_link()));
                json.put("winnerText", Utils.checkNull(giveawayInfo.getWinner_text()));
                json.put("winnerTitle", Utils.checkNull(giveawayInfo.getWinner_title()));
                json.put("count", giveawayInfo.getCount());
                json.put("rewardDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(giveawayInfo.getReward_date()));
                json.put("rewardDate2", new SimpleDateFormat("yyyy.MM.dd").format(giveawayInfo.getReward_date()));
                json.put("rewardTitle", giveawayInfo.getReward_title());
                json.put("rewardImageLink", giveawayInfo.getReward_image_link());
                json.put("rewardImageLink2", giveawayInfo.getReward_image_link2());
                json.put("rewardLink", giveawayInfo.getReward_link());
                json.put("rewardText", giveawayInfo.getReward_text());
                json.put("winnerNum", giveawayInfo.getWinner_num());
            }
            logger.info(new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new Date()).substring(0, 15));

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/selectGiveaway [" + getClass().getSimpleName() + ".selectGiveaway()] end ======");
    }
}
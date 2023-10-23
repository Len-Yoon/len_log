package com.tbnws.gtgear.support.controller;

import com.google.api.services.calendar.model.Event;
import com.google.gson.Gson;
import com.tbnws.gtgear.support.Util.Utils;
import com.tbnws.gtgear.support.model.AdminVO;
import com.tbnws.gtgear.support.model.CalendarVO;
import com.tbnws.gtgear.support.model.EventVO;
import com.tbnws.gtgear.support.model.SubscribeVO;
import io.swagger.annotations.*;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import springfox.documentation.annotations.ApiIgnore;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import static com.tbnws.gtgear.support.config.SwaggerConfig.RESPONSE_PREFIX;

@Api(tags = "EventController", description = "이벤트 관리 API", basePath = "/event")
@Controller
public class EventController extends CommonController {

    private static Logger logger = LoggerFactory.getLogger(com.tbnws.gtgear.support.controller.EventController.class);

    private ApiController apiController = new ApiController();

    @Value("${logistics_calendar_id}")
    String LOGISTICS_CALENDAR_ID;

    @ApiOperation(value = "프리런칭 중복참여 체크", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/checkPrelaunching")
    public void checkPrelaunching(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/checkPrelaunching [" + getClass().getSimpleName() + ".checkPrelaunching()] start ======");
        try {
            String object = Utils.checkNull(request.getParameter("object"));
            String email = Utils.checkNull(request.getParameter("email"));
            String phone = Utils.checkNull(request.getParameter("phone"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/checkPrelaunching [" + getClass().getSimpleName() + ".checkPrelaunching()] object : " + object);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/checkPrelaunching [" + getClass().getSimpleName() + ".checkPrelaunching()] email : " + email);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/checkPrelaunching [" + getClass().getSimpleName() + ".checkPrelaunching()] phone : " + phone);

            int rtn = eventService.checkPrelaunching(object, email, phone);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/checkPrelaunching [" + getClass().getSimpleName() + ".checkPrelaunching()] end ======");
    }

    @ApiOperation(value = "고객 프리런칭 참여 중 옵션1 select", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectPrelaunchingOption1List")
    public void selectPrelaunchingOption1List(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/selectPrelaunchingOption1List [" + getClass().getSimpleName() + ".selectPrelaunchingOption1List()] start ======");
        try {
            String object = request.getParameter("object");
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingOption1List [" + getClass().getSimpleName() + ".selectPrelaunchingOption1List()] object : " + object);

            JSONArray jsonArray = new JSONArray();
            for (EventVO prelaunchingOptionInfo : eventService.selectPrelaunchingOption1List(object)) {
                JSONObject obj = new JSONObject();
                obj.put("frame", prelaunchingOptionInfo.getOption_1());

                jsonArray.add(obj);
            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(jsonArray);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/selectPrelaunchingOption1List [" + getClass().getSimpleName() + ".selectPrelaunchingOption1List()] end ======");
    }

    @RequestMapping(value = "/event/selectPrelaunchingOption2List")
    public void selectPrelaunchingOption2List(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/selectPrelaunchingOption2List [" + getClass().getSimpleName() + ".selectPrelaunchingOption2List()] start ======");
        try {
            String object = request.getParameter("object");
            String option1 = Utils.checkNull(request.getParameter("option1"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingOption2List [" + getClass().getSimpleName() + ".selectPrelaunchingOption2List()] object : " + object);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingOption2List [" + getClass().getSimpleName() + ".selectPrelaunchingOption2List()] option1 : " + option1);

            JSONArray jsonArray = new JSONArray();
            for (EventVO prelaunchingOptionInfo : eventService.selectPrelaunchingOption2List(object, option1)) {
                JSONObject obj = new JSONObject();
                obj.put("option", prelaunchingOptionInfo.getOption_2());

                jsonArray.add(obj);
            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(jsonArray);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/selectPrelaunchingOption2List [" + getClass().getSimpleName() + ".selectPrelaunchingOption2List()] end ======");
    }

    @ApiOperation(value = "프리런칭 insert", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/insertPrelaunchingUserInfo")
    public void insertPrelaunchingUserInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPrelaunchingUserInfo [" + getClass().getSimpleName() + ".insertPrelaunchingUserInfo()] start ======");
        try {
            String object = Utils.checkNull(request.getParameter("object"));
            String email = Utils.checkNull(request.getParameter("email"));
            String phone = Utils.checkNull(request.getParameter("phone"));
            String prelaunchingFlag = Utils.checkNull(request.getParameter("prelaunchingFlag"));
            String option1 = Utils.checkNull(request.getParameter("option1"));
            String option2 = Utils.checkNull(request.getParameter("option2"));
            String brandCode = Utils.checkNull(request.getParameter("brandCode"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPrelaunchingUserInfo [" + getClass().getSimpleName() + ".insertPrelaunchingUserInfo()] object : " + object);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPrelaunchingUserInfo [" + getClass().getSimpleName() + ".insertPrelaunchingUserInfo()] email : " + email);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPrelaunchingUserInfo [" + getClass().getSimpleName() + ".insertPrelaunchingUserInfo()] phone : " + phone);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPrelaunchingUserInfo [" + getClass().getSimpleName() + ".insertPrelaunchingUserInfo()] prelaunchingFlag : " + prelaunchingFlag);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPrelaunchingUserInfo [" + getClass().getSimpleName() + ".insertPrelaunchingUserInfo()] option1 : " + option1);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPrelaunchingUserInfo [" + getClass().getSimpleName() + ".insertPrelaunchingUserInfo()] option2 : " + option2);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPrelaunchingUserInfo [" + getClass().getSimpleName() + ".insertPrelaunchingUserInfo()] brandCode : " + brandCode);

            String title = eventService.selectPrelaunchingInfoTitle(object);
            String senderCodeSMS = "G";

            int rtn = eventService.insertPrelaunchingUserInfo(object, email, phone, prelaunchingFlag, option1, option2, brandCode);

            // mms
            SubscribeVO mmsInfo = subscribeService.selectMessage(object, "SMS");
            if (Utils.isNotEmpty(phone) && mmsInfo != null) {
                String mmsPrefix = "";
                if (object.equals("keychron_newsletter")) {
                    senderCodeSMS = "K";

                    mmsPrefix = "고객님의 키크론 뉴스레터 등록정보는 다음과 같습니다.\n" +
                            "연락처 : " + phone + "\n" +
                            "이메일 : " + email + "\n" +
                            "\n";
                } else {
                    mmsPrefix = "고객님의 " + title + " 프리런칭 참여 등록정보는 다음과 같습니다.\n" +
                            "이메일 : " + email + "\n" +
                            "휴대전화번호 : " + phone + "\n" +
                            "\n";
                }


                String shortUrl = Utils.shortUrl("https://unsubscribe.tbnws.com/sms/" + Utils.md5(phone) + "&title=ToBe%20Admin");

                if (brandCode.equals("brd0029")) {
                    senderCodeSMS = "K";
                }
                String sendMMS = Utils.sendMMS(senderCodeSMS, phone, mmsInfo.getSubject(), mmsPrefix + mmsInfo.getBody(), "SUBSCRIBE");
            }

            // email
            SubscribeVO emailInfo = subscribeService.selectMessage(object, "EMAIL");
            String senderCode = "G";
            if (Utils.isNotEmpty(email) && emailInfo != null) {
                if (emailInfo.getSubject().indexOf("키크론") > -1) {
                    senderCode = "K";
                }
                String sendMail = Utils.sendEmail(senderCode, email, emailInfo.getSubject(), emailInfo.getBody(), "SUBSCRIBE", null);
            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPrelaunchingUserInfo [" + getClass().getSimpleName() + ".insertPrelaunchingUserInfo()] end ======");
    }

    @ApiOperation(value = "프리런칭 관리 DT", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectPreLaunchingList_DT")
    public void selectPreLaunchingList_DT(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPreLaunchingList_DT [" + getClass().getSimpleName() + ".selectPreLaunchingList_DT)] start ======");
        try {
            String categoryCode = Utils.checkNull(request.getParameter("categoryCode"));
            if (categoryCode.isEmpty()) {
                categoryCode = "G";
            }
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectPreLaunchingList_DT [" + getClass().getSimpleName() + ".selectPreLaunchingList_DT()] categoryCode : " + categoryCode);

            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();

            for (EventVO preLaunchingInfo : eventService.selectPreLaunchingList()) {
                JSONObject obj = new JSONObject();
                obj.put("preLaunchingSeq", preLaunchingInfo.getPrelaunching_seq());
                obj.put("preLaunchingTtile", preLaunchingInfo.getPrelaunching_title());
                obj.put("object", preLaunchingInfo.getObject());
                obj.put("registDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(preLaunchingInfo.getRegist_date()));
                obj.put("startDate", new SimpleDateFormat("yyyy-MM-dd").format(preLaunchingInfo.getStart_date()));
                obj.put("endDate", preLaunchingInfo.getEnd_date() == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(preLaunchingInfo.getEnd_date()));
                obj.put("buyStartDate", preLaunchingInfo.getBuy_start_date() == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(preLaunchingInfo.getBuy_start_date()));
                obj.put("buyEndDate", preLaunchingInfo.getBuy_end_date() == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(preLaunchingInfo.getBuy_end_date()));

                jsonArray.add(obj);
            }
            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPreLaunchingList_DT [" + getClass().getSimpleName() + ".selectPreLaunchingList_DT()] " + e);
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPreLaunchingList_DT [" + getClass().getSimpleName() + ".selectPreLaunchingList_DT()] end ======");
    }

    @ApiOperation(value = "프리런칭 추가 리스트 모달창 정보 가져오기", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectPreLaunchingListDetail")
    public void selectPreLaunchingListDetail(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPreLaunchingListDetail [" + getClass().getSimpleName() + ".selectPreLaunchingListDetail()] start ======");
        try {
            int preLaunchingSeq = Utils.checkNullByInt(request.getParameter("preLaunchingSeq"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPreLaunchingListDetail [" + getClass().getSimpleName() + ".selectPreLaunchingListDetail()] preLaunchingSeq : " + preLaunchingSeq);

            EventVO detailInfo = eventService.selectPreLaunchingListDetail(preLaunchingSeq);
            JSONObject json = new JSONObject();
            json.put("preLaunchingTitle", detailInfo.getPrelaunching_title());
            json.put("object", detailInfo.getObject());
            json.put("registDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(detailInfo.getRegist_date()));
            json.put("startDate", new SimpleDateFormat("yyyy-MM-dd").format(detailInfo.getStart_date()));
            json.put("endDate", detailInfo.getEnd_date() == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(detailInfo.getEnd_date()));
            json.put("buyStartDate", detailInfo.getBuy_start_date() == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(detailInfo.getBuy_start_date()));
            json.put("buyEndDate", detailInfo.getBuy_end_date() == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(detailInfo.getBuy_end_date()));
            json.put("url", detailInfo.getUrl());

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPreLaunchingListDetail [" + getClass().getSimpleName() + ".selectPreLaunchingListDetail()] end ======");
    }
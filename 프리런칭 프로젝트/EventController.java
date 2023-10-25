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

    @ApiOperation(value = "프리런칭 추가 리스트 모달창 정보 가져오기", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectPreLaunchingListDetailItem")
    public void selectPreLaunchingListDetailItem(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPreLaunchingListDetailItem [" + getClass().getSimpleName() + ".selectPreLaunchingListDetailItem()] start ======");
        try {
            int preLaunchingSeq = Utils.checkNullByInt(request.getParameter("preLaunchingSeq"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPreLaunchingListDetailItem [" + getClass().getSimpleName() + ".selectPreLaunchingListDetailItem()] preLaunchingSeq : " + preLaunchingSeq);

            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();

            for (EventVO itemInfo : eventService.selectPreLaunchingListDetailItem(preLaunchingSeq)) {
                JSONObject obj = new JSONObject();
                obj.put("seq", itemInfo.getSeq());
                obj.put("preLaunchingType", itemInfo.getPrelaunching_type());
                obj.put("categoryCode", itemInfo.getCategory_code());
                obj.put("brandCode", itemInfo.getBrand_code());
                obj.put("goodsCode", itemInfo.getGoods_code());
                obj.put("optionCode", itemInfo.getOption_code());

                jsonArray.add(obj);
            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(jsonArray);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPreLaunchingListDetailItem [" + getClass().getSimpleName() + ".selectPreLaunchingListDetailItem()] end ======");
    }

    @ApiOperation(value = "프리런칭 현황 insert", notes = "Len.yun")
    @RequestMapping(value = "/event/insertPreLaunchingList")
    public void insertPreLaunchingList(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingList [" + getClass().getSimpleName() + ".insertPreLaunchingList()] start ======");
        try {
            String preLaunchingTitle = Utils.checkNull(request.getParameter("preLaunchingTitle"));
            String preLaunchingSeq = Utils.checkNull(request.getParameter("preLaunchingSeq"));
            String object = Utils.checkNull(request.getParameter("object"));
            String startDate = Utils.checkNull(request.getParameter("startDate"));
            String endDate = Utils.checkNull(request.getParameter("endDate"));
            String buyStartDate = Utils.checkNull(request.getParameter("buyStartDate"));
            String buyEndDate = Utils.checkNull(request.getParameter("buyEndDate"));
            String url = Utils.checkNull(request.getParameter("url"));
            String brandCode = Utils.checkNull(request.getParameter("brandCode"));

            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingList [" + getClass().getSimpleName() + ".insertPreLaunchingList()] preLaunchingTitle : " + preLaunchingTitle);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingList [" + getClass().getSimpleName() + ".insertPreLaunchingList()] preLaunchingSeq : " + preLaunchingSeq);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingList [" + getClass().getSimpleName() + ".insertPreLaunchingList()] object : " + object);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingList [" + getClass().getSimpleName() + ".insertPreLaunchingList()] startDate : " + startDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingList [" + getClass().getSimpleName() + ".insertPreLaunchingList()] endDate : " + endDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingList [" + getClass().getSimpleName() + ".insertPreLaunchingList()] buyStartDate : " + buyStartDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingList [" + getClass().getSimpleName() + ".insertPreLaunchingList()] buyEndDate : " + buyEndDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingList [" + getClass().getSimpleName() + ".insertPreLaunchingList()] url : " + url);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingList [" + getClass().getSimpleName() + ".insertPreLaunchingList()] brandCode : " + brandCode);

            EventVO detailInfo = new EventVO();
            detailInfo.setPrelaunching_title(preLaunchingTitle);
            detailInfo.setObject(object);
            detailInfo.setUrl(url);
            detailInfo.setBrand_code(brandCode);
            detailInfo.setStart_date(new SimpleDateFormat("yyyy-MM-dd").parse(startDate));
            if (endDate != "") {
                detailInfo.setEnd_date(new SimpleDateFormat("yyyy-MM-dd").parse(endDate));
            }
            if (buyStartDate != "") {
                detailInfo.setBuy_start_date(new SimpleDateFormat("yyyy-MM-dd").parse(buyStartDate));
            }
            if (buyEndDate != "") {
                detailInfo.setBuy_end_date(new SimpleDateFormat("yyyy-MM-dd").parse(buyEndDate));
            }

            int rtn = eventService.insertPreLaunchingList(detailInfo);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingList [" + getClass().getSimpleName() + ".insertPreLaunchingList()] rtn : " + rtn);

            if (rtn > 0) {
                EventVO insertMessage = new EventVO();
                insertMessage.setId(object);
                insertMessage.setType("EMAIL");
                int messageRtn = eventService.insertMessageList(insertMessage);

                if (messageRtn > 0) {
                    insertMessage.setId(object);
                    insertMessage.setType("SMS");
                    eventService.insertMessageList(insertMessage);
                }

                if (Utils.isNotEmpty(buyStartDate)) {
                    insertMessage.setId(object);
                    insertMessage.setType("PRELAUNCHING");
                    eventService.insertMessageList(insertMessage);
                }
            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingList [" + getClass().getSimpleName() + ".insertPreLaunchingList()] end ======");
    }

    @ApiOperation(value = "프리런칭 현황 item insert", notes = "Len.yun")
    @RequestMapping(value = "/event/insertPreLaunchingListItem")
    public void insertPreLaunchingListItem(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingListItem [" + getClass().getSimpleName() + ".insertPreLaunchingListItem()] start ======");
        try {
            int preLaunchingSeq = Integer.parseInt(Utils.checkNull(request.getParameter("preLaunchingSeq")));
            String categoryCode = Utils.checkNull(request.getParameter("categoryCode"));
            String brandCode = Utils.checkNull(request.getParameter("brandCode"));
            String goodsCode = Utils.checkNull(request.getParameter("goodsCode"));
            String optionCode = Utils.checkNull(request.getParameter("optionCode"));
            String preLaunchingType = Utils.checkNull(request.getParameter("preLaunchingType"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingListItem [" + getClass().getSimpleName() + ".insertPreLaunchingListItem()] preLaunchingSeq : " + preLaunchingSeq);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingListItem [" + getClass().getSimpleName() + ".insertPreLaunchingListItem()] categoryCode : " + categoryCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingListItem [" + getClass().getSimpleName() + ".insertPreLaunchingListItem()] brandCode : " + brandCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingListItem [" + getClass().getSimpleName() + ".insertPreLaunchingListItem()] goodsCode : " + goodsCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingListItem [" + getClass().getSimpleName() + ".insertPreLaunchingListItem()] optionCode : " + optionCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingListItem [" + getClass().getSimpleName() + ".insertPreLaunchingListItem()] preLaunchingType : " + preLaunchingType);

            EventVO detailItemInfo = new EventVO();
            detailItemInfo.setPrelaunching_seq(preLaunchingSeq);
            detailItemInfo.setCategory_code(categoryCode);
            detailItemInfo.setBrand_code(brandCode);
            detailItemInfo.setGoods_code(goodsCode);
            detailItemInfo.setOption_code(optionCode);
            detailItemInfo.setPrelaunching_type(preLaunchingType);

            int rtn = eventService.insertPreLaunchingListItem(detailItemInfo);

            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingListItem [" + getClass().getSimpleName() + ".insertPreLaunchingListItem()] rtn : " + rtn);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPreLaunchingListItem [" + getClass().getSimpleName() + ".insertPreLaunchingListItem()] end ======");
    }

    @ApiOperation(value = "프리런칭 현황 update", notes = "Len.yun")
    @RequestMapping(value = "/event/updatePreLaunchingList")
    public void updatePreLaunchingList(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePreLaunchingList [" + getClass().getSimpleName() + ".updatePreLaunchingList()] start ======");
        try {
            String preLaunchingTitle = Utils.checkNull(request.getParameter("preLaunchingTitle"));
            int preLaunchingSeq = Utils.checkNullByInt(request.getParameter("preLaunchingSeq"));
            String object = Utils.checkNull(request.getParameter("object"));
            String startDate = Utils.checkNull(request.getParameter("startDate"));
            String endDate = Utils.checkNull(request.getParameter("endDate"));
            String buyStartDate = Utils.checkNull(request.getParameter("buyStartDate"));
            String buyEndDate = Utils.checkNull(request.getParameter("buyEndDate"));
            String url = Utils.checkNull(request.getParameter("url"));
            String brandCode = Utils.checkNull(request.getParameter("brandCode"));

            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePreLaunchingList [" + getClass().getSimpleName() + ".updatePreLaunchingList()] preLaunchingTitle : " + preLaunchingTitle);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePreLaunchingList [" + getClass().getSimpleName() + ".updatePreLaunchingList()] preLaunchingSeq : " + preLaunchingSeq);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePreLaunchingList [" + getClass().getSimpleName() + ".updatePreLaunchingList()] object : " + object);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePreLaunchingList [" + getClass().getSimpleName() + ".updatePreLaunchingList()] startDate : " + startDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePreLaunchingList [" + getClass().getSimpleName() + ".updatePreLaunchingList()] endDate : " + endDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePreLaunchingList [" + getClass().getSimpleName() + ".updatePreLaunchingList()] buyStartDate : " + buyStartDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePreLaunchingList [" + getClass().getSimpleName() + ".updatePreLaunchingList()] buyEndDate : " + buyEndDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePreLaunchingList [" + getClass().getSimpleName() + ".updatePreLaunchingList()] url : " + url);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePreLaunchingList [" + getClass().getSimpleName() + ".updatePreLaunchingList()] brandCode : " + brandCode);

            EventVO detailInfo = new EventVO();
            detailInfo.setPrelaunching_seq(preLaunchingSeq);
            detailInfo.setPrelaunching_title(preLaunchingTitle);
            detailInfo.setObject(object);
            detailInfo.setUrl(url);
            detailInfo.setBrand_code(brandCode);
            detailInfo.setStart_date(new SimpleDateFormat("yyyy-MM-dd").parse(startDate));
            if (endDate != "") {
                detailInfo.setEnd_date(new SimpleDateFormat("yyyy-MM-dd").parse(endDate));
            }
            if (buyStartDate != "") {
                detailInfo.setBuy_start_date(new SimpleDateFormat("yyyy-MM-dd").parse(buyStartDate));
            }
            if (buyEndDate != "") {
                detailInfo.setBuy_end_date(new SimpleDateFormat("yyyy-MM-dd").parse(buyEndDate));
            }

            int rtn = eventService.updatePreLaunchingList(detailInfo);

            if (rtn != -1) {
                rtn = eventService.deletePreLaunchingItemList(preLaunchingSeq);
                eventService.deletePrelaunchingOption(object);
                eventService.deletePrelaunchingSubscribeItem(object);
            }

            SubscribeVO mmsInfo = subscribeService.selectMessage(object, "PRELAUNCHING");

            if (Utils.isNotEmpty(buyStartDate) && mmsInfo == null) {
                EventVO insertMessage = new EventVO();
                insertMessage.setId(object);
                insertMessage.setType("PRELAUNCHING");
                eventService.insertMessageList(insertMessage);
            }

            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePreLaunchingList [" + getClass().getSimpleName() + ".updatePreLaunchingList()] rtn : " + rtn);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePreLaunchingList [" + getClass().getSimpleName() + ".updatePreLaunchingList()] end ======");
    }

    @ApiOperation(value = " 프리런칭 정보 삭제", notes = "Len.Yun")
    @RequestMapping(value = "/event/deletePreLaunchingList")
    public void deletePreLaunchingList(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/deletePreLaunchingList [" + getClass().getSimpleName() + ".deletePreLaunchingList()] start ======");
        try {
            int preLaunchingSeq = Utils.checkNullByInt(request.getParameter("preLaunchingSeq"));
            String preLaunchingObject = Utils.checkNull(request.getParameter("preLaunchingObject"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/deletePreLaunchingList [" + getClass().getSimpleName() + ".deletePreLaunchingList()] preLaunchingSeq : " + preLaunchingSeq);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/deletePreLaunchingList [" + getClass().getSimpleName() + ".deletePreLaunchingList()] preLaunchingObject : " + preLaunchingObject);

            int rtn = eventService.deletePreLaunchingList(preLaunchingSeq);

            if (rtn > 0) {
                eventService.deleteMessageList(preLaunchingObject, "");
                eventService.deletePrelaunchingOption(preLaunchingObject);
            }

            if (rtn != -1) {
                rtn = eventService.deletePreLaunchingItemList(preLaunchingSeq);
            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/deletePreLaunchingList [" + getClass().getSimpleName() + ".deletePreLaunchingList()] end ======");
    }

    @ApiOperation(value = "프리런칭 옵션 select", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectPreLaunchingOptionList")
    public void selectPreLaunchingOptionList(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/selectPreLaunchingOptionList [" + getClass().getSimpleName() + ".selectPreLaunchingOptionList()] start ======");
        try {
            String object = request.getParameter("object");
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPreLaunchingOptionList [" + getClass().getSimpleName() + ".selectPreLaunchingOptionList()] object : " + object);

            JSONArray jsonArray = new JSONArray();
            for (EventVO prelaunchingOptionInfo : eventService.selectPreLaunchingOptionList(object)) {
                JSONObject obj = new JSONObject();
                obj.put("option1", prelaunchingOptionInfo.getOption_1());
                obj.put("option2", prelaunchingOptionInfo.getOption_2());

                jsonArray.add(obj);
            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(jsonArray);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/selectNewPrelaunchingCounting [" + getClass().getSimpleName() + ".selectNewPrelaunchingCounting()] end ======");
    }

    @ApiOperation(value = "프리런칭 옵션추가", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/insertPrelauchingOption")
    public void insertPrelauchingOption(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/insertPrelauchingOption [" + getClass().getSimpleName() + ".insertPrelauchingOption()] start ======");
        try {
            String object = request.getParameter("object");
            String option1 = request.getParameter("option1");
            String option2 = request.getParameter("option2");
            String type = request.getParameter("type");
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPrelauchingOption [" + getClass().getSimpleName() + ".insertPrelauchingOption()] object : " + object);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPrelauchingOption [" + getClass().getSimpleName() + ".insertPrelauchingOption()] option1 : " + option1);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPrelauchingOption [" + getClass().getSimpleName() + ".insertPrelauchingOption()] option2 : " + option2);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertPrelauchingOption [" + getClass().getSimpleName() + ".insertPrelauchingOption()] type : " + type);

            int rtn = eventService.insertPrelauchingOption(object, option1, option2);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /api/insertPrelauchingOption [" + getClass().getSimpleName() + ".insertPrelauchingOption()] end ======");
    }

    @ApiOperation(value = "프리런칭 옵션선택 update", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/updatePrelaunchingOption")
    public void updatePrelaunchingOption(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingOption [" + getClass().getSimpleName() + ".updatePrelaunchingOption()] start ======");
        try {
            String option1 = Utils.checkNull(request.getParameter("option1"));
            String option2 = Utils.checkNull(request.getParameter("option2"));
            int seq = Utils.checkNullByInt(request.getParameter("seq"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingOption [" + getClass().getSimpleName() + ".updatePrelaunchingOption()] option1 : " + option1);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingOption [" + getClass().getSimpleName() + ".updatePrelaunchingOption()] option2 : " + option2);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingOption [" + getClass().getSimpleName() + ".updatePrelaunchingOption()] seq : " + seq);

            int rtn = eventService.updatePrelaunchingOption(option1, option2, seq);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingOption [" + getClass().getSimpleName() + ".updatePrelaunchingOption()] end ======");
    }

    @ApiOperation(value = "전체 프리런칭리스트 조회 API", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectPrelaunchingList_DT")
    public void selectPrelaunchingList_DT(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingList_DT [" + getClass().getSimpleName() + ".selectPrelaunchingList_DT()] start ======");
        try {

            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            for (EventVO prelaunchingListInfo : eventService.selectPrelaunchingList_DT()) {
                JSONObject obj = new JSONObject();
                obj.put("object", Utils.checkNull(prelaunchingListInfo.getObject()));
                obj.put("count", prelaunchingListInfo.getCount());
                obj.put("startDate", new SimpleDateFormat("yyyy-MM-dd").format(prelaunchingListInfo.getStart_date()));
                if (prelaunchingListInfo.getEnd_date() != null) {
                    obj.put("endDate", new SimpleDateFormat("yyyy-MM-dd").format(prelaunchingListInfo.getEnd_date()));
                } else {
                    obj.put("endDate", null);
                }
                jsonArray.add(obj);
            }

            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingList_DT [" + getClass().getSimpleName() + ".selectPrelaunchingList_DT()] " + e);
            e.printStackTrace();
        }
        log(request);
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingList_DT [" + getClass().getSimpleName() + ".selectPrelaunchingList_DT()] end ======");
    }

    @ApiOperation(value = "프리런칭 그래프 정보 조회 API", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectPrelaunchingStates")
    public void selectPrelaunchingStats(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingStats [" + getClass().getSimpleName() + ".selectPrelaunchingStats()] start ======");
        try {
            String startDate = Utils.checkNull(request.getParameter("startDate"));
            String endDate = Utils.checkNull(request.getParameter("endDate"));
            String chartDate = Utils.checkNull(request.getParameter("chartDate"));

            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingStats [" + getClass().getSimpleName() + ".selectPrelaunchingStats()] startDate : " + startDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingStats [" + getClass().getSimpleName() + ".selectPrelaunchingStats()] endDate : " + endDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingStats [" + getClass().getSimpleName() + ".selectPrelaunchingStats()] chartDate : " + chartDate);

            String chartDateType = "";
            if (chartDate.equals("day")) {
                chartDateType = "%Y-%m-%d";
            } else if (chartDate.equals("week")) {
                chartDateType = "%Y-%U";
            } else if (chartDate.equals("month")) {
                chartDateType = "%Y-%m";
            }

            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            JSONObject obj = new JSONObject();

            String date = "";
            int count = 0;
            String flag = "N";

            for (EventVO prelaunchingStats : eventService.getPrelaunchingStats(startDate, endDate, chartDateType)) {
                if (!date.equals(prelaunchingStats.getEvent_date())) {
                    if (flag.equals("Y")) {
                        jsonArray.add(obj);
                    } else {
                        flag = "Y";
                    }

                    date = prelaunchingStats.getEvent_date();
                    count = 0;

                    obj = new JSONObject();
                }
                obj.put("date", prelaunchingStats.getEvent_date());
                obj.put(prelaunchingStats.getObject(), prelaunchingStats.getCount());
                count += prelaunchingStats.getCount();
                obj.put("count", count);


            }
            jsonArray.add(obj);
            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingStats [" + getClass().getSimpleName() + ".selectPrelaunchingStats()] end ======");
    }

    @ApiOperation(value = "프리런칭 정보 조회 API", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectPrelaunchingInfo")
    public void selectPrelaunchingInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingInfo [" + getClass().getSimpleName() + ".selectPrelaunchingInfo()] start ======");
        try {
            String object = Utils.checkNull(request.getParameter("object"));
            if (Utils.isEmpty(object)) {
                List<EventVO> objectList = eventService.selectPrelaunchingObjectList();
                object = objectList.get(0).getObject();
            }
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingInfo [" + getClass().getSimpleName() + ".selectPrelaunchingInfo()] object : " + object);

            EventVO preLaunchingInfo = eventService.selectPrelaunchingInfo(object);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(new Gson().toJson(preLaunchingInfo));
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingInfo [" + getClass().getSimpleName() + ".selectPrelaunchingInfo()] end ======");
    }

    @ApiOperation(value = "프리런칭 현황 조회 API", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectPrelaunchingUserInfo_DT")
    public void selectPrelaunching_DT(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingUserInfo_DT [" + getClass().getSimpleName() + ".selectPrelaunchingUserInfo_DT()] start ======");
        try {
            String object = Utils.checkNull(request.getParameter("object"));
            if (Utils.isEmpty(object)) {
                List<EventVO> objectList = eventService.selectPrelaunchingObjectList();
                object = objectList.get(0).getObject();
            }
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingUserInfo_DT [" + getClass().getSimpleName() + ".selectPrelaunchingUserInfo_DT()] object : " + object);

            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            for (EventVO prelaunchingInfo : eventService.selectPrelaunchingUserInfo_DT(object)) {
                JSONObject obj = new JSONObject();
                obj.put("seq", prelaunchingInfo.getSeq());
                obj.put("object", Utils.checkNull(prelaunchingInfo.getObject()));
                obj.put("email", Utils.checkNull(prelaunchingInfo.getEmail()));
                obj.put("phone", Utils.checkNull(prelaunchingInfo.getPhone()));
                obj.put("keyboardFrame", Utils.checkNull(prelaunchingInfo.getKeyboard_frame()));
                obj.put("keyboardSwitch", prelaunchingInfo.getKeyboard_switch());
                obj.put("prelaunchingDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(prelaunchingInfo.getPrelaunching_date()));
                obj.put("exportSeq", prelaunchingInfo.getExport_seq());
                obj.put("prelaunchingFlag", prelaunchingInfo.getPrelaunching_flag());
                obj.put("option1", prelaunchingInfo.getOption_1());
                obj.put("option2", prelaunchingInfo.getOption_2());
                jsonArray.add(obj);
            }
            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingUserInfo_DT [" + getClass().getSimpleName() + ".selectPrelaunchingUserInfo_DT()] " + e);
            e.printStackTrace();
        }
        log(request);
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingUserInfo_DT [" + getClass().getSimpleName() + ".selectPrelaunchingUserInfo_DT()] end ======");
    }

    @ApiOperation(value = "프리런칭 자동참여자 Count 조회", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectAutoPrelaunchingCount")
    public void selectAutoPrelaunchingCount(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectAutoPrelaunchingCount [" + getClass().getSimpleName() + ".selectAutoPrelaunchingCount()] start ======");
        try {
            String object = Utils.checkNull(request.getParameter("object"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectAutoPrelaunchingCount [" + getClass().getSimpleName() + ".selectAutoPrelaunchingCount()] object : " + object);

            List<EventVO> countList = eventService.selectAutoPrelaunchingCount(object);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectAutoPrelaunchingCount [" + getClass().getSimpleName() + ".selectAutoPrelaunchingCount()] switchCountList.size() : " + countList.size());

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(new Gson().toJson(countList));
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingSwitchCountList [" + getClass().getSimpleName() + ".selectPrelaunchingSwitchCountList()] end ======");
    }

    @ApiOperation(value = "프레임 별 프리런칭 통계 조회 API", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectPrelaunchingFrameCountList")
    public void selectPrelaunchingFrameCountList(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingFrameCountList [" + getClass().getSimpleName() + ".selectPrelaunchingFrameCountList()] start ======");
        try {
            String object = Utils.checkNull(request.getParameter("object"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingFrameCountList [" + getClass().getSimpleName() + ".selectPrelaunchingFrameCountList()] object : " + object);

            List<EventVO> frameCountList = eventService.selectPrelaunchingFrameCountList(object);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingFrameCountList [" + getClass().getSimpleName() + ".selectPrelaunchingFrameCountList()] frameCountList.size() : " + frameCountList.size());

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(new Gson().toJson(frameCountList));
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingFrameCountList [" + getClass().getSimpleName() + ".selectPrelaunchingFrameCountList()] end ======");
    }

    @ApiOperation(value = "스위치 별 프리런칭 통계 조회 API", httpMethod = "GET", notes = "Len.yun")
    @RequestMapping(value = "/event/selectPrelaunchingSwitchCountList")
    public void selectPrelaunchingSwitchCountList(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingSwitchCountList [" + getClass().getSimpleName() + ".selectPrelaunchingSwitchCountList()] start ======");
        try {
            String object = Utils.checkNull(request.getParameter("object"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingSwitchCountList [" + getClass().getSimpleName() + ".selectSwitchCselectPrelaunchingSwitchCountListountList()] object : " + object);

            List<EventVO> switchCountList = eventService.selectPrelaunchingSwitchCountList(object);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingSwitchCountList [" + getClass().getSimpleName() + ".selectPrelaunchingSwitchCountList()] switchCountList.size() : " + switchCountList.size());

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(new Gson().toJson(switchCountList));
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingSwitchCountList [" + getClass().getSimpleName() + ".selectPrelaunchingSwitchCountList()] end ======");
    }

    @ApiOperation(value = "프리런칭 정보 조회 API", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectPrelaunchingUserInfo")
    public void selectPrelaunchingUserInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingUserInfo [" + getClass().getSimpleName() + ".selectPrelaunchingUserInfo()] start ======");
        try {
            int seq = Utils.checkNullByInt(request.getParameter("seq"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingUserInfo [" + getClass().getSimpleName() + ".selectPrelaunchingUserInfo()] seq : " + seq);

            EventVO subscribeInfo = eventService.selectPrelaunchingUserInfo(seq);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(new Gson().toJson(subscribeInfo));
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectPrelaunchingUserInfo [" + getClass().getSimpleName() + ".selectPrelaunchingUserInfo()] end ======");
    }

    @ApiOperation(value = "프리런칭 정보 수정 API", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/updatePrelaunchingInfo")
    public void updatePrelaunchingInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingInfo [" + getClass().getSimpleName() + ".updatePrelaunchingInfo()] start ======");
        try {
            int seq = Utils.checkNullByInt(request.getParameter("seq"));
            String object = Utils.checkNull(request.getParameter("object"));
            String email = Utils.checkNull(request.getParameter("email"));
            String phone = Utils.checkNull(request.getParameter("phone"));
            String option1 = Utils.checkNull(request.getParameter("option1"));
            String option2 = Utils.checkNull(request.getParameter("option2"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingInfo [" + getClass().getSimpleName() + ".updatePrelaunchingInfo()] seq : " + seq);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingInfo [" + getClass().getSimpleName() + ".updatePrelaunchingInfo()] object : " + object);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingInfo [" + getClass().getSimpleName() + ".updatePrelaunchingInfo()] email : " + email);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingInfo [" + getClass().getSimpleName() + ".updatePrelaunchingInfo()] phone : " + phone);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingInfo [" + getClass().getSimpleName() + ".updatePrelaunchingInfo()] option1 : " + option1);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingInfo [" + getClass().getSimpleName() + ".updatePrelaunchingInfo()] option2 : " + option2);

            int rtn = eventService.updatePrelaunchingInfo(seq, object, email, phone, option1, option2);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingInfo [" + getClass().getSimpleName() + ".updatePrelaunchingInfo()] rtn : " + rtn);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/updatePrelaunchingInfo [" + getClass().getSimpleName() + ".updatePrelaunchingInfo()] end ======");
    }

    @ApiOperation(value = "프리런칭 정보 삭제 API", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/deletePrelaunchingInfo")
    public void deletePrelaunchingInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/deletePrelaunchingInfo [" + getClass().getSimpleName() + ".deletePrelaunchingInfo()] start ======");
        try {
            int seq = Utils.checkNullByInt(request.getParameter("seq"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/deletePrelaunchingInfo [" + getClass().getSimpleName() + ".deletePrelaunchingInfo()] seq : " + seq);

            int rtn = eventService.deletePrelaunchingInfo(seq);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/deletePrelaunchingInfo [" + getClass().getSimpleName() + ".deletePrelaunchingInfo()] rtn : " + rtn);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/deletePrelaunchingInfo [" + getClass().getSimpleName() + ".deletePrelaunchingInfo()] end ======");
    }

}

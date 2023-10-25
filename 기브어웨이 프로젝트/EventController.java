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

    @ApiOperation(value = "기브어웨이 추가 리스트 DataTable 자료", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectGiveawayEventList_DT")
    public void selectGiveawayEventList_DT(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayEventList_DT [" + getClass().getSimpleName() + ".selectGiveawayEventList_DT()] start ======");
        try {
            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            for (EventVO addListInfo : eventService.selectGiveawayEventList_DT()) {
                JSONObject obj = new JSONObject();
                obj.put("giveawaySeq", addListInfo.getGiveaway_seq());
                obj.put("giveawayTitle", Utils.checkNull(addListInfo.getGiveaway_title()));
                obj.put("startDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(addListInfo.getStart_date()));
                obj.put("endDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(addListInfo.getEnd_date()));
                obj.put("rewardDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(addListInfo.getReward_date()));
                obj.put("object", Utils.checkNull(addListInfo.getObject()));
                obj.put("giveawayType", Utils.checkNull(addListInfo.getGiveaway_type()));
                jsonArray.add(obj);
            }
            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayEventList_DT [" + getClass().getSimpleName() + ".selectGiveawayEventList_DT()] end ======");
    }

    @ApiOperation(value = "기브어웨이 이벤트 입력", notes = "Len.Yun")
    @RequestMapping(value = "/event/insertGiveawayEvent")
    public void insertGiveawayEvent(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] start ======");
        try {
            int rtn = -1;

            String giveawayType = Utils.checkNull(request.getParameter("giveawayType"));
            String object = Utils.checkNull(request.getParameter("object"));
            String giveawayTitle = Utils.checkNull(request.getParameter("giveawayTitle"));
            String startDate = Utils.checkNull(request.getParameter("startDate"));
            String endDate = Utils.checkNull(request.getParameter("endDate"));
            String rewardDate = Utils.checkNull(request.getParameter("rewardDate"));
            String giveawayText = Utils.checkNull(request.getParameter("giveawayText"));
            String successText = Utils.checkNull(request.getParameter("successText"));
            String buttonText = Utils.checkNull(request.getParameter("buttonText"));
            String buttonLink = Utils.checkNull(request.getParameter("buttonLink"));
            String buttonFlag = Utils.checkNull(request.getParameter("buttonFlag"));
            String homeSub = Utils.checkNull(request.getParameter("homeSub"));
            String homeMain = Utils.checkNull(request.getParameter("homeMain"));
            String homeLink = Utils.checkNull(request.getParameter("homeLink"));
            String winnerTitle = Utils.checkNull(request.getParameter("winnerTitle"));
            String winnerText = Utils.checkNull(request.getParameter("winnerText"));
            String winnerLink = Utils.checkNull(request.getParameter("winnerLink"));
            String couponTitle = Utils.checkNull(request.getParameter("couponTitle"));
            String couponLink = Utils.checkNull(request.getParameter("couponLink"));
            String rewardTitle = Utils.checkNull(request.getParameter("rewardTitle"));
            String rewardImageLink = Utils.checkNull(request.getParameter("rewardImageLink"));
            String rewardImageLink2 = Utils.checkNull(request.getParameter("rewardImageLink2"));
            String rewardLink = Utils.checkNull(request.getParameter("rewardLink"));
            String rewardText = Utils.checkNull(request.getParameter("rewardText"));
            int winnerNum = Utils.checkNullByInt(request.getParameter("winnerNum"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] giveawayType : " + giveawayType);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] object : " + object);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] giveawayTitle : " + giveawayTitle);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] startDate : " + startDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] endDate : " + endDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] rewardDate : " + rewardDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] giveawayText : " + giveawayText);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] successText : " + successText);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] buttonText : " + buttonText);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] buttonLink : " + buttonLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] buttonFlag : " + buttonFlag);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] homeSub : " + homeSub);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] homeMain : " + homeMain);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] homeLink : " + homeLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] winnerTitle : " + winnerTitle);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] winnerText : " + winnerText);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] winnerLink : " + winnerLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] couponTitle : " + couponTitle);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] couponLink : " + couponLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] rewardTitle : " + rewardTitle);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] rewardImageLink : " + rewardImageLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] rewardImageLink2 : " + rewardImageLink2);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] rewardLink : " + rewardLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] rewardText : " + rewardText);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] winnerNum : " + winnerNum);

            EventVO addListInfo = new EventVO();
            addListInfo.setGiveaway_type(giveawayType);
            addListInfo.setObject(object);
            addListInfo.setGiveaway_title(giveawayTitle);
            addListInfo.setStart_date(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(startDate));
            addListInfo.setEnd_date(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(endDate));
            addListInfo.setReward_date(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(rewardDate));
            addListInfo.setGiveaway_text(giveawayText);
            addListInfo.setSuccess_text(successText);
            addListInfo.setButton_flag(buttonFlag);
            addListInfo.setButton_text(buttonText);
            addListInfo.setButton_link(buttonLink);
            addListInfo.setHome_sub(homeSub);
            addListInfo.setHome_main(homeMain);
            addListInfo.setHome_link(homeLink);
            addListInfo.setWinner_text(winnerText);
            addListInfo.setWinner_title(winnerTitle);
            addListInfo.setWinner_link(winnerLink);
            addListInfo.setCoupon_title(couponTitle);
            addListInfo.setCoupon_link(couponLink);
            addListInfo.setReward_title(rewardTitle);
            addListInfo.setReward_image_link(rewardImageLink);
            addListInfo.setReward_image_link2(rewardImageLink2);
            addListInfo.setReward_link(rewardLink);
            addListInfo.setReward_text(rewardText);
            addListInfo.setWinner_num(winnerNum);

            rtn = eventService.insertGiveawayEvent(addListInfo);

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

            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEvent [" + getClass().getSimpleName() + ".insertGiveawayEvent()] end ======");
    }

    @ApiOperation(value = "기브어웨이 추가 이미지 링크 추가", notes = "Len.Yun")
    @RequestMapping(value = "/event/insertGiveawayEventImage")
    public void insertGiveawayEventImage(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEventImage [" + getClass().getSimpleName() + ".insertGiveawayEventImage()] start ======");
        try {
            int giveawaySeq = Utils.checkNullByInt(request.getParameter("giveawaySeq"));
            String imageLink = Utils.checkNull(request.getParameter("imageLink"));
            String type = Utils.checkNull(request.getParameter("type"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEventImage [" + getClass().getSimpleName() + ".insertGiveawayEventImage()] giveawaySeq : " + giveawaySeq);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEventImage [" + getClass().getSimpleName() + ".insertGiveawayEventImage()] imageLink : " + imageLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEventImage [" + getClass().getSimpleName() + ".insertGiveawayEventImage()] type : " + type);

            EventVO addListInfo = new EventVO();
            addListInfo.setGiveaway_seq(giveawaySeq);
            addListInfo.setLink(imageLink);
            addListInfo.setType(type);

            int rtn = eventService.insertGiveawayEventImage(addListInfo);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEventImage [" + getClass().getSimpleName() + ".insertGiveawayEventImage()] end ======");
    }

    @ApiOperation(value = "기브어웨이 추가 미션 추가", notes = "Len.Yun")
    @RequestMapping(value = "/event/insertGiveawayEventMission")
    public void insertAddListMission(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEventMission [" + getClass().getSimpleName() + ".insertGiveawayEventMission()] start ======");
        try {
            int giveawaySeq = Utils.checkNullByInt(request.getParameter("giveawaySeq"));
            String iconLink = Utils.checkNull(request.getParameter("iconLink"));
            String missionText = Utils.checkNull(request.getParameter("missionText"));
            String missionLink = Utils.checkNull(request.getParameter("missionLink"));
            String type = Utils.checkNull(request.getParameter("type"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEventMission [" + getClass().getSimpleName() + ".insertGiveawayEventMission()] giveawaySeq : " + giveawaySeq);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEventMission [" + getClass().getSimpleName() + ".insertGiveawayEventMission()] iconLink : " + iconLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEventMission [" + getClass().getSimpleName() + ".insertGiveawayEventMission()] missionText : " + missionText);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEventMission [" + getClass().getSimpleName() + ".insertGiveawayEventMission()] missionLink : " + missionLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEventMission [" + getClass().getSimpleName() + ".insertGiveawayEventMission()] type : " + type);

            EventVO addListInfo = new EventVO();
            addListInfo.setGiveaway_seq(giveawaySeq);
            addListInfo.setMission_icon(iconLink);
            addListInfo.setMission_title(missionText);
            addListInfo.setLink(missionLink);
            addListInfo.setType(type);

            int rtn = eventService.insertGiveawayEventMission(addListInfo);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/insertGiveawayEventMission [" + getClass().getSimpleName() + ".insertGiveawayEventMission()] end ======");
    }

    @ApiOperation(value = "기브어웨이 추가 리스트 모달창 정보 가져오기", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectGiveawayEventDetail")
    public void selectGiveawayEventDetail(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayEventDetail [" + getClass().getSimpleName() + ".selectGiveawayEventDetail()] start ======");
        try {
            int giveawaySeq = Utils.checkNullByInt(request.getParameter("giveawaySeq"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayEventDetail [" + getClass().getSimpleName() + ".selectGiveawayEventDetail()] giveawaySeq : " + giveawaySeq);

            EventVO detailInfo = eventService.selectGiveawayEventDetail(giveawaySeq);
            JSONObject json = new JSONObject();
            json.put("giveawayTitle", Utils.checkNull(detailInfo.getGiveaway_title()));
            json.put("giveawayText", Utils.checkNull(detailInfo.getGiveaway_text()));
            json.put("startDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(detailInfo.getStart_date()));
            json.put("endDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(detailInfo.getEnd_date()));
            json.put("object", Utils.checkNull(detailInfo.getObject()));
            json.put("successText", Utils.checkNull(detailInfo.getSuccess_text()));
            json.put("buttonFlag", Utils.checkNull(detailInfo.getButton_flag()));
            json.put("buttonText", Utils.checkNull(detailInfo.getButton_text()));
            json.put("buttonLink", Utils.checkNull(detailInfo.getButton_link()));
            json.put("homeSub", Utils.checkNull(detailInfo.getHome_sub()));
            json.put("homeMain", Utils.checkNull(detailInfo.getHome_main()));
            json.put("homeLink", Utils.checkNull(detailInfo.getHome_link()));
            json.put("winnerTitle", Utils.checkNull(detailInfo.getWinner_title()));
            json.put("winnerText", Utils.checkNull(detailInfo.getWinner_text()));
            json.put("winnerLink", Utils.checkNull(detailInfo.getWinner_link()));
            json.put("couponTitle", Utils.checkNull(detailInfo.getCoupon_title()));
            json.put("couponLink", Utils.checkNull(detailInfo.getCoupon_link()));
            json.put("giveawayType", Utils.checkNull(detailInfo.getGiveaway_type()));
            json.put("rewardDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(detailInfo.getReward_date()));
            json.put("rewardDate2", new SimpleDateFormat("yyyy.MM.dd").format(detailInfo.getReward_date()));
            json.put("rewardTitle", Utils.checkNull(detailInfo.getReward_title()));
            json.put("rewardImageLink", Utils.checkNull(detailInfo.getReward_image_link()));
            json.put("rewardImageLink2", Utils.checkNull(detailInfo.getReward_image_link2()));
            json.put("rewardLink", Utils.checkNull(detailInfo.getReward_link()));
            json.put("rewardText", Utils.checkNull(detailInfo.getReward_text()));
            json.put("winnerNum", detailInfo.getWinner_num());

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayEventDetail [" + getClass().getSimpleName() + ".selectGiveawayEventDetail()] end ======");
    }

    @ApiOperation(value = "기브어웨이 추가 리스트 모달창 이미지,미션 정보", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectGiveawayEventItemDetail")
    public void selectGiveawayEventItemDetail(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayEventItemDetail [" + getClass().getSimpleName() + ".selectGiveawayEventItemDetail()] start ======");
        try {
            int giveawaySeq = Utils.checkNullByInt(request.getParameter("giveawaySeq"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayEventItemDetail [" + getClass().getSimpleName() + ".selectGiveawayEventItemDetail()] giveawaySeq : " + giveawaySeq);

            JSONArray jsonArray = new JSONArray();
            for (EventVO detailInfo : eventService.selectGiveawayEventItemDetail(giveawaySeq)) {
                JSONObject obj = new JSONObject();
                obj.put("type", Utils.checkNull(detailInfo.getType()));
                obj.put("link", Utils.checkNull(detailInfo.getLink()));
                obj.put("missionTitle", Utils.checkNull(detailInfo.getMission_title()));
                obj.put("missionIcon", Utils.checkNull(detailInfo.getMission_icon()));
                jsonArray.add(obj);
            }
            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(jsonArray);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayEventItemDetail [" + getClass().getSimpleName() + ".selectGiveawayEventItemDetail()] end ======");
    }

    @ApiOperation(value = "기브어웨이 추가 모달창 업데이트", notes = "Len.Yun")
    @RequestMapping(value = "/event/updateGiveawayEvent")
    public void updateGiveawayEvent(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] start ======");
        try {
            int rtn = -1;
            int rtn2 = -1;

            String giveawayType = Utils.checkNull(request.getParameter("giveawayType"));
            String object = Utils.checkNull(request.getParameter("object"));
            String giveawayTitle = Utils.checkNull(request.getParameter("giveawayTitle"));
            String startDate = Utils.checkNull(request.getParameter("startDate"));
            String endDate = Utils.checkNull(request.getParameter("endDate"));
            String rewardDate = Utils.checkNull(request.getParameter("rewardDate"));
            String giveawayText = Utils.checkNull(request.getParameter("giveawayText"));
            String successText = Utils.checkNull(request.getParameter("successText"));
            int giveawaySeq = Utils.checkNullByInt(request.getParameter("giveawaySeq"));
            String buttonText = Utils.checkNull(request.getParameter("buttonText"));
            String buttonLink = Utils.checkNull(request.getParameter("buttonLink"));
            String buttonFlag = Utils.checkNull(request.getParameter("buttonFlag"));
            String homeSub = Utils.checkNull(request.getParameter("homeSub"));
            String homeMain = Utils.checkNull(request.getParameter("homeMain"));
            String homeLink = Utils.checkNull(request.getParameter("homeLink"));
            String winnerTitle = Utils.checkNull(request.getParameter("winnerTitle"));
            String winnerText = Utils.checkNull(request.getParameter("winnerText"));
            String winnerLink = Utils.checkNull(request.getParameter("winnerLink"));
            String couponTitle = Utils.checkNull(request.getParameter("couponTitle"));
            String couponLink = Utils.checkNull(request.getParameter("couponLink"));
            String rewardTitle = Utils.checkNull(request.getParameter("rewardTitle"));
            String rewardImageLink = Utils.checkNull(request.getParameter("rewardImageLink"));
            String rewardImageLink2 = Utils.checkNull(request.getParameter("rewardImageLink2"));
            String rewardLink = Utils.checkNull(request.getParameter("rewardLink"));
            String rewardText = Utils.checkNull(request.getParameter("rewardText"));
            int winnerNum = Utils.checkNullByInt(request.getParameter("winnerNum"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] giveawayType : " + giveawayType);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] object : " + object);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] giveawayTitle : " + giveawayTitle);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] startDate : " + startDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] endDate : " + endDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] rewardDate : " + rewardDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] giveawayText : " + giveawayText);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] successText : " + successText);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] giveawaySeq : " + giveawaySeq);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] buttonText : " + buttonText);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] buttonLink : " + buttonLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] buttonFlag : " + buttonFlag);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] homeSub : " + homeSub);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] homeMain : " + homeMain);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] homeLink : " + homeLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] winnerTitle : " + winnerTitle);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] winnerText : " + winnerText);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] winnerLink : " + winnerLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] couponTitle : " + couponTitle);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] couponLink : " + couponLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] rewardTitle : " + rewardTitle);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] rewardImageLink : " + rewardImageLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] rewardImageLink2 : " + rewardImageLink2);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] rewardLink : " + rewardLink);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] rewardText : " + rewardText);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayEvent [" + getClass().getSimpleName() + ".updateGiveawayEvent()] winnerNum : " + winnerNum);

            EventVO addListInfo = new EventVO();
            addListInfo.setGiveaway_type(giveawayType);
            addListInfo.setObject(object);
            addListInfo.setGiveaway_title(giveawayTitle);
            addListInfo.setStart_date(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(startDate));
            addListInfo.setEnd_date(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(endDate));
            addListInfo.setReward_date(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(rewardDate));
            addListInfo.setGiveaway_text(giveawayText);
            addListInfo.setSuccess_text(successText);
            addListInfo.setGiveaway_seq(giveawaySeq);
            addListInfo.setButton_flag(buttonFlag);
            addListInfo.setButton_text(buttonText);
            addListInfo.setButton_link(buttonLink);
            addListInfo.setHome_sub(homeSub);
            addListInfo.setHome_main(homeMain);
            addListInfo.setHome_link(homeLink);
            addListInfo.setWinner_text(winnerText);
            addListInfo.setWinner_title(winnerTitle);
            addListInfo.setWinner_link(winnerLink);
            addListInfo.setCoupon_title(couponTitle);
            addListInfo.setCoupon_link(couponLink);
            addListInfo.setReward_title(rewardTitle);
            addListInfo.setReward_image_link(rewardImageLink);
            addListInfo.setReward_image_link2(rewardImageLink2);
            addListInfo.setReward_link(rewardLink);
            addListInfo.setReward_text(rewardText);
            addListInfo.setWinner_num(winnerNum);

            rtn = eventService.updateGiveawayEvent(addListInfo);

            if (rtn != -1) {
                rtn2 = eventService.deleteGiveawayEventItem(giveawaySeq);
            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn2);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateAddList [" + getClass().getSimpleName() + ".updateAddList()] end ======");
    }

    @ApiOperation(value = "기브어웨이 이벤트 추가 정보 삭제", notes = "Len.Yun")
    @RequestMapping(value = "/event/deleteGiveawayEvent")
    public void deleteGiveawayEvent(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/deleteGiveawayEvent [" + getClass().getSimpleName() + ".deleteGiveawayEvent()] start ======");
        try {
            int rtn = -1;

            int giveawaySeq = Utils.checkNullByInt(request.getParameter("giveawaySeq"));
            String messageObject = Utils.checkNull(request.getParameter("messageObject"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/deleteGiveawayEvent [" + getClass().getSimpleName() + ".deleteGiveawayEvent()] giveawaySeq : " + giveawaySeq);

            rtn = eventService.deleteGiveawayEvent(giveawaySeq);

            if (rtn != -1) {
                int rtn2 = eventService.deleteGiveawayEventItem(giveawaySeq);

                response.setCharacterEncoding("UTF-8");
                response.setContentType("text/html; charset=UTF-8");
                response.getWriter().print(rtn2);
            }

            if (rtn > 0) {
                eventService.deleteMessageList(messageObject, "");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/deleteGiveawayEvent [" + getClass().getSimpleName() + ".deleteGiveawayEvent()] end ======");
    }

    @ApiOperation(value = "기브어웨이 랜딩페이지 리스트 select", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectGiveawayList_DT")
    public void selectGiveawayList_DT(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayList_DT [" + getClass().getSimpleName() + ".selectGiveawayList_DT()] start ======");
        try {
            String startDate = Utils.checkNull(request.getParameter("startDate"));
            String endDate = Utils.checkNull(request.getParameter("endDate"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectSubscribeStats [" + getClass().getSimpleName() + ".selectSubscribeStats()] startDate : " + startDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectSubscribeStats [" + getClass().getSimpleName() + ".selectSubscribeStats()] endDate : " + endDate);

            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            for (EventVO giveawayListInfo : eventService.selectGiveawayList_DT(startDate, endDate)) {
                JSONObject obj = new JSONObject();
                obj.put("giveawayTitle", Utils.checkNull(giveawayListInfo.getGiveaway_title()));
                obj.put("giveawayType", Utils.checkNull(giveawayListInfo.getGiveaway_type()));
                obj.put("object", Utils.checkNull(giveawayListInfo.getObject()));
                obj.put("startDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(giveawayListInfo.getStart_date()));
                obj.put("endDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(giveawayListInfo.getEnd_date()));
                obj.put("count", giveawayListInfo.getCount());
                jsonArray.add(obj);
            }
            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /erp/selectGiveawayList_DT [" + getClass().getSimpleName() + ".selectGiveawayList_DT()] end ======");
    }

    @ApiOperation(value = "기브어웨이 랜딩페이지 그래프 정보 조회 API", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectGiveawayListStates")
    public void selectGiveawayListStats(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayListStats [" + getClass().getSimpleName() + ".selectGiveawayListStats()] start ======");
        try {
            String startDate = Utils.checkNull(request.getParameter("startDate"));
            String endDate = Utils.checkNull(request.getParameter("endDate"));
            String chartDate = Utils.checkNull(request.getParameter("chartDate"));

            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayListStats [" + getClass().getSimpleName() + ".selectGiveawayListStats()] startDate : " + startDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayListStats [" + getClass().getSimpleName() + ".selectGiveawayListStats()] endDate : " + endDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayListStats [" + getClass().getSimpleName() + ".selectGiveawayListStats()] chartDate : " + chartDate);

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
            String giveawayTitle = "";
            int count = 0;
            String flag = "N";

            for (EventVO giveawayStats : eventService.getGiveawayListStats(startDate, endDate, chartDateType)) {
                if (!date.equals(giveawayStats.getEvent_date())) {
                    if (flag.equals("Y")) {
                        jsonArray.add(obj);
                    } else {
                        flag = "Y";
                    }

                    date = giveawayStats.getEvent_date();
                    giveawayTitle = giveawayStats.getGiveaway_title();
                    count = 0;

                    obj = new JSONObject();
                }
                obj.put("date", giveawayStats.getEvent_date());
                obj.put(giveawayStats.getGiveaway_title(), giveawayStats.getCount());
                count += giveawayStats.getCount();
                obj.put("count", count);
                obj.put("giveawayTitle", giveawayTitle);
            }
            jsonArray.add(obj);
            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayListStats [" + getClass().getSimpleName() + ".selectGiveawayListStats()] end ======");
    }

    @ApiOperation(value = "giveawayResult 유저 정보 list select", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectGiveawayUserInfo_DT")
    public void selectGiveawayUserInfo_DT(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayUserInfo_DT [" + getClass().getSimpleName() + ".selectGiveawayUserInfo_DT()] start ======");
        try {
            String giveawayTitle = request.getParameter("giveawayTitle");
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayUserInfo_DT [" + getClass().getSimpleName() + ".selectGiveawayUserInfo_DT()] giveawayTitle : " + giveawayTitle);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayUserInfo_DT [" + getClass().getSimpleName() + ".selectGiveawayUserInfo_DT()] startDate : " + startDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayUserInfo_DT [" + getClass().getSimpleName() + ".selectGiveawayUserInfo_DT()] endDate : " + endDate);

            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            for (EventVO giveawayInfo : eventService.selectGiveawayUserInfo_DT(giveawayTitle, startDate, endDate)) {
                JSONObject obj = new JSONObject();
                obj.put("userSeq", giveawayInfo.getUser_seq());
                obj.put("giveawayTitle", giveawayInfo.getGiveaway_title());
                obj.put("userEmail", giveawayInfo.getUser_email());
                obj.put("userPhone", giveawayInfo.getUser_phone());
                obj.put("object", giveawayInfo.getObject());
                obj.put("registDate", giveawayInfo.getRegist_date() == null ? "" : new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(giveawayInfo.getRegist_date()));
                obj.put("count", giveawayInfo.getCount());
                jsonArray.add(obj);
            }
            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayUserInfo_DT [" + getClass().getSimpleName() + ".selectGiveawayUserInfo_DT()] end ======");
    }

    @ApiOperation(value = "giveawayResult 그래프 정보 list", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectGiveawayStates")
    public void selectGiveawayStats(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayStates [" + getClass().getSimpleName() + ".selectGiveawayStates()] start ======");
        try {
            String giveawayTitle = request.getParameter("giveawayTitle");
            String startDate = Utils.checkNull(request.getParameter("startDate"));
            String endDate = Utils.checkNull(request.getParameter("endDate"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayStates [" + getClass().getSimpleName() + ".selectGiveawayStates()] giveawayTitle : " + giveawayTitle);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayStates [" + getClass().getSimpleName() + ".selectGiveawayStates()] startDate : " + startDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayStates [" + getClass().getSimpleName() + ".selectGiveawayStates()] endDate : " + endDate);

            //데이터 전달
            JSONArray jsonArray = new JSONArray();
            for (EventVO giveawayCountList : eventService.selectGiveawayStats(giveawayTitle, startDate, endDate)) {
                JSONObject obj = new JSONObject();
                obj.put("date", new SimpleDateFormat("yyyy-MM-dd").format(giveawayCountList.getDate()));
                obj.put("count", giveawayCountList.getCount());
                jsonArray.add(obj);
            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(jsonArray);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayStates [" + getClass().getSimpleName() + ".selectGiveawayStates()] end ======");
    }

    @RequestMapping("/event/selectGiveawayUserInfo")
    public void selectGiveawayUserInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayUserInfo [" + getClass().getSimpleName() + ".selectGiveawayUserInfo()] start ======");
        try {
            String giveawaySeq = request.getParameter("giveawaySeq");
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayUserInfo [" + getClass().getSimpleName() + ".selectGiveawayUserInfo()] giveawaySeq : " + giveawaySeq);

            EventVO giveawayUserInfo = eventService.selectGiveawayUserInfo(giveawaySeq);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(new Gson().toJson(giveawayUserInfo));
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayInfo [" + getClass().getSimpleName() + ".selectGiveawayInfo()] end ======");
    }

    @ApiOperation(value = "기브어웨이참여정보 삭제 API", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/deleteGiveawayUserInfo")
    public void deleteGiveawayUserInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/deleteGiveawayUserInfo [" + getClass().getSimpleName() + ".deleteGiveawayUserInfo()] start ======");
        try {
            int seq = Utils.checkNullByInt(request.getParameter("seq"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/deleteGiveawayUserInfo [" + getClass().getSimpleName() + ".deleteGiveawayUserInfo()] seq : " + seq);

            int rtn = eventService.deleteGiveawayUserInfo(seq);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/deleteGiveawayUserInfo [" + getClass().getSimpleName() + ".deleteGiveawayUserInfo()] rtn : " + rtn);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/deleteGiveawayUserInfo [" + getClass().getSimpleName() + ".deleteGiveawayUserInfo()] end ======");
    }

    @ApiOperation(value = "기브어웨이참여정보 수정 API", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping(value = "/event/updateGiveawayUserInfo")
    public void updateGiveawayUserInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayUserInfo [" + getClass().getSimpleName() + ".updateGiveawayUserInfo()] start ======");
        try {
            int seq = Utils.checkNullByInt(request.getParameter("seq"));
            String object = Utils.checkNull(request.getParameter("object"));
            String email = Utils.checkNull(request.getParameter("email"));
            String phone = Utils.checkNull(request.getParameter("phone"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayUserInfo [" + getClass().getSimpleName() + ".updateGiveawayUserInfo()] seq : " + seq);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayUserInfo [" + getClass().getSimpleName() + ".updateGiveawayUserInfo()] object : " + object);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayUserInfo [" + getClass().getSimpleName() + ".updateGiveawayUserInfo()] email : " + email);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayUserInfo [" + getClass().getSimpleName() + ".updateGiveawayUserInfo()] phone : " + phone);

            int rtn = eventService.updateGiveawayUserInfo(seq, object, email, phone);
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayUserInfo [" + getClass().getSimpleName() + ".updateGiveawayUserInfo()] rtn : " + rtn);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/updateGiveawayUserInfo [" + getClass().getSimpleName() + ".updateGiveawayUserInfo()] end ======");
    }

    @ApiOperation(value = "기브어웨이 공홈용 자료 가져오기", notes = "Len.Yun")
    @RequestMapping(value = "/event/selectGiveawayhome")
    public void selectGiveawayhome(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayhome [" + getClass().getSimpleName() + ".selectGiveawayhome()] start ======");
        try {
            String giveawayType = Utils.checkNull(request.getParameter("giveawayType"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayhome [" + getClass().getSimpleName() + ".selectGiveawayhome()] giveawayType : " + giveawayType);

            Date now = new Date();

            JSONArray jsonArray = new JSONArray();
            for (EventVO giveawayHome : eventService.selectGiveawayhome(giveawayType)) {
                JSONObject obj = new JSONObject();
                obj.put("startDate", new SimpleDateFormat("yyyy-MM-dd").format(giveawayHome.getStart_date()));
                obj.put("endDate", new SimpleDateFormat("yyyy-MM-dd").format(giveawayHome.getEnd_date()));
                obj.put("homeSub", Utils.checkNull(giveawayHome.getHome_sub()));
                obj.put("homeMain", Utils.checkNull(giveawayHome.getHome_main()));
                obj.put("homeLink", Utils.checkNull(giveawayHome.getHome_link()));
                obj.put("winnerTitle", Utils.checkNull(giveawayHome.getWinner_title()));
                obj.put("winnerText", Utils.checkNull(giveawayHome.getWinner_text()));
                obj.put("winnerLink", Utils.checkNull(giveawayHome.getWinner_link()));
                obj.put("object", Utils.checkNull(giveawayHome.getObject()));
                obj.put("count", giveawayHome.getCount());
                obj.put("startDateTime", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(giveawayHome.getStart_date()));
                obj.put("endDateTime", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(giveawayHome.getEnd_date()));
                obj.put("giveawayType", Utils.checkNull(giveawayHome.getGiveaway_type()));
                if (now.after(giveawayHome.getStart_date()) && now.before(giveawayHome.getEnd_date())) {
                    obj.put("timeFlag", "ing");
                } else if (now.before(giveawayHome.getStart_date())) {
                    obj.put("timeFlag", "ready");
                } else if (now.after(giveawayHome.getEnd_date())) {
                    obj.put("timeFlag", "end");
                }
                obj.put("rewardLink", Utils.checkNull(giveawayHome.getReward_link()));
                obj.put("rewardDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(giveawayHome.getReward_date()));

                jsonArray.add(obj);
            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(jsonArray);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /event/selectGiveawayhome [" + getClass().getSimpleName() + ".selectGiveawayhome()] end ======");
    }
}

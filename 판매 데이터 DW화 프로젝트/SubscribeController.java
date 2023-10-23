package com.tbnws.gtgear.support.controller;

import com.google.gson.Gson;
import com.tbnws.gtgear.support.Util.Utils;
import com.tbnws.gtgear.support.model.AdminVO;
import com.tbnws.gtgear.support.model.SubscribeVO;
import com.tbnws.gtgear.support.model.SupportVO;
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
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import springfox.documentation.annotations.ApiIgnore;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.text.SimpleDateFormat;
import java.util.*;

import static com.tbnws.gtgear.support.config.SwaggerConfig.RESPONSE_PREFIX;

@Api(tags = "SubscribeController", description = "사전 예약 API", basePath = "/subscribe")
@CrossOrigin
@Controller
public class SubscribeController extends CommonController {

    private static Logger logger = LoggerFactory.getLogger(SubscribeController.class);

    @Value("${email_auth_address}")
    String EMAIL_AUTH_ADDRESS;

    @Value("${email_auth_password}")
    String EMAIL_AUTH_PASSWORD;

    @ApiOperation(value = "DW grade 데이터 insert", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping("/insertDwGradeList")
    public void insertDwGradeList(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /insertDwGradeList [" + getClass().getSimpleName() + ".insertDwGradeList()] start ======");
        try {
            String gradeDate = "";
            String type = "A";

            //가장 최근 DW데이터화 한 date 조회
            String lastGradeDate = supportService.selectLastGradeDate();
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            String now = dateFormat.format(new Date());

            Date date1 = new SimpleDateFormat("yyyy-MM-dd").parse(lastGradeDate);
            Date date2 = new SimpleDateFormat("yyyy-MM-dd").parse(now);

            int daydiff = (int) ((date2.getTime() - date1.getTime()) / (24*60*60*1000));

            for(int i = 1; i < daydiff; i++) {
                Date date = dateFormat.parse(lastGradeDate);
                java.util.Calendar cal = java.util.Calendar.getInstance();
                cal.setTime(date);

                cal.add(java.util.Calendar.DATE,i);
                gradeDate = dateFormat.format(cal.getTime());

                //전날 데이터 저장하기위해 DW화 가공
                for(SupportVO gradeInfo : supportService.selectAllGradeList(type, gradeDate, "", "", "")) {
                    String brandCode_a = gradeInfo.getBrand_code();
                    String goodsCode_a = gradeInfo.getGoods_code();
                    String optionCode_a = Utils.checkNull(gradeInfo.getOption_code());
                    Double availableMonth = Math.round(gradeInfo.getAvailable_month()*10)/10.0;

                    if(brandCode_a.equals("brd0080")) continue;
                    if(brandCode_a.equals("brd0102")) continue;
                    if(brandCode_a.equals("brd0073")) continue;
                    if(brandCode_a.equals("brd0001") && goodsCode_a.equals("gs0001")) continue;
                    if(brandCode_a.equals("brd0001") && goodsCode_a.equals("gs0002")) continue;

                    String grade = "";
                    if (availableMonth <= 0) grade = "X";
                    else if (availableMonth < 5) grade = "A";
                    else if (availableMonth < 10) grade = "B";
                    else if (availableMonth < 30) grade = "C";
                    else if (availableMonth < 50) grade = "D";
                    else if (availableMonth < 70) grade = "E";
                    else if (availableMonth < 100) grade = "F";
                    else grade = "G";

                    //DW DB데이터 insert
                    int rtn = supportService.insertDwGrade(gradeDate, brandCode_a, goodsCode_a, optionCode_a, availableMonth);

                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /insertDwGradeList [" + getClass().getSimpleName() + ".insertDwGradeList()] end ======");
    }

    @ApiOperation(value = "DW grade 데이터 update", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping("/updateDwGradeList")
    public void updateDwGradeList(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /updateDwGradeList [" + getClass().getSimpleName() + ".insertDwGradeList()] start ======");
        try {
            String gradeDate = "";
            String type = "A";

            String lastGradeDate = request.getParameter("startDate");
            String brandCode = Utils.checkNull(request.getParameter("brandCode"));
            String goodsCode = Utils.checkNull(request.getParameter("goodsCode"));
            String optionCode = Utils.checkNull(request.getParameter("optionCode"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /updateDwGradeList [" + getClass().getSimpleName() + ".updateDwGradeList()] lastGradeDate : " + lastGradeDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /updateDwGradeList [" + getClass().getSimpleName() + ".updateDwGradeList()] brandCode : " + brandCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /updateDwGradeList [" + getClass().getSimpleName() + ".updateDwGradeList()] goodsCode : " + goodsCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /updateDwGradeList [" + getClass().getSimpleName() + ".updateDwGradeList()] optionCode : " + optionCode);

            int deleteRtn = supportService.deleteDwGrade(lastGradeDate, brandCode, goodsCode, optionCode);

            if(deleteRtn >= 0) {
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                String now = dateFormat.format(new Date());

                Date date1 = new SimpleDateFormat("yyyy-MM-dd").parse(lastGradeDate);
                Date date2 = new SimpleDateFormat("yyyy-MM-dd").parse(now);

                int daydiff = (int) ((date2.getTime() - date1.getTime()) / (24*60*60*1000));

                for(int i = 0; i < daydiff; i++) {
                    Date date = dateFormat.parse(lastGradeDate);
                    java.util.Calendar cal = java.util.Calendar.getInstance();
                    cal.setTime(date);

                    cal.add(java.util.Calendar.DATE,i);
                    gradeDate = dateFormat.format(cal.getTime());

                    for(SupportVO gradeInfo : supportService.selectAllGradeList(type, gradeDate, brandCode, goodsCode, optionCode)) {
                        String brandCode_a = Utils.checkNull(gradeInfo.getBrand_code());
                        String goodsCode_a = Utils.checkNull(gradeInfo.getGoods_code());
                        String optionCode_a = Utils.checkNull(gradeInfo.getOption_code());
                        Double availableMonth = Math.round(gradeInfo.getAvailable_month()*10)/10.0;

                        if(brandCode_a.equals("brd0080")) continue;
                        if(brandCode_a.equals("brd0102")) continue;
                        if(brandCode_a.equals("brd0073")) continue;

                        int rtn = supportService.insertDwGrade(gradeDate, brandCode_a, goodsCode_a, optionCode_a, availableMonth);
                    }
                }
            }


        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /updateDwGradeList [" + getClass().getSimpleName() + ".updateDwGradeList()] end ======");
    }

    @ApiOperation(value = "상품 검색 제품 리스트", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping("/selectSearchList")
    public void selectSearchList(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectSearchList [" + getClass().getSimpleName() + ".selectSearchList()] start ======");
        try {

            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            for(SupportVO goodsInfo : supportService.selectSearchList()) {
                JSONObject obj = new JSONObject();

                obj.put("brandCode", goodsInfo.getBrand_code());
                obj.put("brandName", goodsInfo.getBrand_name());
                obj.put("goodsCode", goodsInfo.getGoods_code());
                obj.put("goodsName", goodsInfo.getGoods_name());
                obj.put("optionCode", Utils.checkNull(goodsInfo.getOption_code()));
                obj.put("optionName", Utils.checkNull(goodsInfo.getOption_name()));
                obj.put("actualPrice", goodsInfo.getActual_price());
                obj.put("duty", goodsInfo.getDuty());

                jsonArray.add(obj);
            }
            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectSearchList [" + getClass().getSimpleName() + ".selectSearchList()] end ======");
    }

    @ApiOperation(value = "상품 검색 제품 정보", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping("/selectTrafficInfo")
    public void selectTrafficInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectTrafficInfo [" + getClass().getSimpleName() + ".selectTrafficInfo()] start ======");
        try {
            String brandCode = Utils.checkNull(request.getParameter("brandCode"));
            String goodsCode = Utils.checkNull(request.getParameter("goodsCode"));
            String optionCode = Utils.checkNull(request.getParameter("optionCode"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectTrafficInfo [" + getClass().getSimpleName() + ".selectTrafficInfo()] brandCode : " + brandCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectTrafficInfo [" + getClass().getSimpleName() + ".selectTrafficInfo()] goodsCode : " + goodsCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectTrafficInfo [" + getClass().getSimpleName() + ".selectTrafficInfo()] optionCode : " + optionCode);

            String goodsName = supportService.selectGoodsName(brandCode, goodsCode, optionCode);
            logger.info("goodsName ==" + goodsName);
            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            for(SupportVO goodsInfo : supportService.selectTrafficInfo(brandCode, goodsCode, optionCode)) {
                JSONObject obj = new JSONObject();


                obj.put("g_ea", goodsInfo.getG_ea());
                obj.put("f_ea", goodsInfo.getF_ea());
                obj.put("g_be_due_ea", goodsInfo.getG_be_due_ea());
                obj.put("f_be_due_ea", goodsInfo.getF_be_due_ea());
                obj.put("g_schedule_ea", goodsInfo.getG_schedule_ea());
                obj.put("f_schedule_ea", goodsInfo.getF_schedule_ea());
                obj.put("buying_price", goodsInfo.getBuying_price());
                obj.put("date_diff", goodsInfo.getDate_diff());
                obj.put("order_date", goodsInfo.getOrder_date() == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(goodsInfo.getOrder_date()));
                obj.put("vat_flag", Utils.checkNull(goodsInfo.getVat_flag()));
                obj.put("goodsName", goodsName);
                obj.put("orderSeq", goodsInfo.getOrder_seq());
                obj.put("importDate", goodsInfo.getImport_date() == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(goodsInfo.getImport_date()));

                jsonArray.add(obj);
            }
            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectTrafficInfo [" + getClass().getSimpleName() + ".selectTrafficInfo()] end ======");
    }

    @ApiOperation(value = "상품 검색 제품 Grade", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping("/selectOrderTableInfo")
    public void selectOrderTableInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectOrderTableInfo [" + getClass().getSimpleName() + ".selectOrderTableInfo()] start ======");
        try {
            String orderSeq = Utils.checkNull(request.getParameter("orderSeq"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectOrderTableInfo [" + getClass().getSimpleName() + ".selectOrderTableInfo()] orderSeq : " + orderSeq);

            SupportVO orderTableInfo = supportService.selectOrderTableInfo(orderSeq);

            JSONObject json = new JSONObject();
            json.put("orderDate", orderTableInfo.getOrder_date() == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(orderTableInfo.getOrder_date()));
            json.put("arrFlag", orderTableInfo.getArr_flag());
            json.put("arrDate", orderTableInfo.getArr_date() == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(orderTableInfo.getArr_date()));

            logger.info("json == " + json);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectOrderTableInfo [" + getClass().getSimpleName() + ".selectOrderTableInfo()] end ======");
    }

    @ApiOperation(value = "상품 buying price 조회", notes = "Len.Yun")
    @RequestMapping("/selectBuyingPriceInfo")
    public void selectBuyingPriceInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectBuyingPriceInfo [" + getClass().getSimpleName() + ".selectBuyingPriceInfo()] start ======");
        try {
            String brandCode = Utils.checkNull(request.getParameter("brandCode"));
            String goodsCode = Utils.checkNull(request.getParameter("goodsCode"));
            String optionCode = Utils.checkNull(request.getParameter("optionCode"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectBuyingPriceInfo [" + getClass().getSimpleName() + ".selectBuyingPriceInfo()] brandCode : " + brandCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectBuyingPriceInfo [" + getClass().getSimpleName() + ".selectBuyingPriceInfo()] goodsCode : " + goodsCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectBuyingPriceInfo [" + getClass().getSimpleName() + ".selectBuyingPriceInfo()] optionCode : " + optionCode);

            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            for(SupportVO buyingPriceInfo : supportService.selectBuyingPriceInfo(brandCode, goodsCode, optionCode)) {
                JSONObject obj = new JSONObject();
                obj.put("buyingPrice", buyingPriceInfo.getBuying_price());
                obj.put("currency", buyingPriceInfo.getCurrency());
                obj.put("cur2krw", buyingPriceInfo.getCur2krw());
                obj.put("orderDate", buyingPriceInfo.getOrder_date() == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(buyingPriceInfo.getOrder_date()));

                jsonArray.add(obj);
            }
            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectMemo_DT [" + getClass().getSimpleName() + ".selectMemo_DT()] end ======");
    }

    @ApiOperation(value = "상품 메모 리스트", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping("/selectMemo_DT")
    public void selectMemo_DT(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectMemo_DT [" + getClass().getSimpleName() + ".selectMemo_DT()] start ======");
        try {
            String brandCode = Utils.checkNull(request.getParameter("brandCode"));
            String goodsCode = Utils.checkNull(request.getParameter("goodsCode"));
            String optionCode = Utils.checkNull(request.getParameter("optionCode"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectMemo_DT [" + getClass().getSimpleName() + ".selectMemo_DT()] brandCode : " + brandCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectMemo_DT [" + getClass().getSimpleName() + ".selectMemo_DT()] goodsCode : " + goodsCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectMemo_DT [" + getClass().getSimpleName() + ".selectMemo_DT()] optionCode : " + optionCode);

            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            for(SupportVO memoInfo : supportService.selectMemo(brandCode, goodsCode, optionCode)) {
                JSONObject obj = new JSONObject();
                obj.put("seq", memoInfo.getSeq());
                obj.put("memo", Utils.checkNull(memoInfo.getMemo()));
                obj.put("registDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(memoInfo.getRegist_date()));
                obj.put("name", Utils.checkNull(memoInfo.getName()));

                jsonArray.add(obj);
            }
            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectMemo_DT [" + getClass().getSimpleName() + ".selectMemo_DT()] end ======");
    }

    @ApiOperation(value = "상품 메모 기간 내 모든 리스트", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping("/selectAllSearchMemoList")
    public void selectAllSearchMemoList(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectAllSearchMemoList [" + getClass().getSimpleName() + ".selectAllSearchMemoList()] start ======");
        try {
            String startMemoDate = Utils.checkNull(request.getParameter("startMemoDate"));
            String endMemoDate = Utils.checkNull(request.getParameter("endMemoDate"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectAllSearchMemoList [" + getClass().getSimpleName() + ".selectAllSearchMemoList()] startMemoDate : " + startMemoDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectAllSearchMemoList [" + getClass().getSimpleName() + ".selectAllSearchMemoList()] endMemoDate : " + endMemoDate);

            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            for(SupportVO memoInfo : supportService.selectAllSearchMemoList(startMemoDate, endMemoDate)) {
                JSONObject obj = new JSONObject();
                String brandCode = Utils.checkNull(memoInfo.getBrand_code());
                String goodsCode = Utils.checkNull(memoInfo.getGoods_code());
                String optionCode = Utils.checkNull(memoInfo.getOption_code());
                String code = "";
                if(optionCode.isEmpty()) {
                    code = brandCode.replace("brd","") + "-" + goodsCode.replaceAll("gs","");
                } else {
                    code = brandCode.replace("brd","") + "-" + goodsCode.replaceAll("gs","") + "-" + optionCode.replace("opt","");
                }
                obj.put("brandCode", memoInfo.getBrand_code());
                obj.put("goodsCode", memoInfo.getGoods_code());
                obj.put("optionCode", Utils.checkNull(memoInfo.getOption_code()));
                obj.put("code",code);
                obj.put("memo", Utils.checkNull(memoInfo.getMemo()));
                obj.put("registDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(memoInfo.getRegist_date()));
                obj.put("name", Utils.checkNull(memoInfo.getName()));
                obj.put("brandName", Utils.checkNull(memoInfo.getBrand_name()));
                obj.put("goodsName", Utils.checkNull(memoInfo.getGoods_name()));
                obj.put("optionName", Utils.checkNull(memoInfo.getOption_name()));

                jsonArray.add(obj);
            }
            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectMemo_DT [" + getClass().getSimpleName() + ".selectMemo_DT()] end ======");
    }

    @ApiOperation(value = "상품 메모 정보", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping("/selectGoodsMemoInfo")
    public void selectGoodsMemoInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectGoodsMemoInfo [" + getClass().getSimpleName() + ".selectGoodsMemoInfo()] start ======");
        try {
            String seq = Utils.checkNull(request.getParameter("seq"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectGoodsMemoInfo [" + getClass().getSimpleName() + ".selectGoodsMemoInfo()] seq : " + seq);

            JSONObject json = new JSONObject();

            SupportVO memoInfo = supportService.selectGoodsMemoInfo(seq);
            json.put("memo", Utils.checkNull(memoInfo.getMemo()));

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectGoodsMemoInfo [" + getClass().getSimpleName() + ".selectGoodsMemoInfo()] end ======");
    }

    @ApiOperation(value = "상품 메모 추가", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping("/insertGoodsMemoInfo")
    public void insertGoodsMemoInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /insertGoodsMemoInfo [" + getClass().getSimpleName() + ".insertGoodsMemoInfo()] start ======");
        try {
            String brandCode = Utils.checkNull(request.getParameter("brandCode"));
            String goodsCode = Utils.checkNull(request.getParameter("goodsCode"));
            String optionCode = Utils.checkNull(request.getParameter("optionCode"));
            String memo = Utils.checkNull(request.getParameter("memo"));
            String uid = Utils.checkNull(((AdminVO) session.getAttribute("MemberInfo")).getUid());
            logger.info("[" + request.getRemoteAddr() + "] ====== /insertGoodsMemoInfo [" + getClass().getSimpleName() + ".insertGoodsMemoInfo()] brandCode : " + brandCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /insertGoodsMemoInfo [" + getClass().getSimpleName() + ".insertGoodsMemoInfo()] goodsCode : " + goodsCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /insertGoodsMemoInfo [" + getClass().getSimpleName() + ".insertGoodsMemoInfo()] optionCode : " + optionCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /insertGoodsMemoInfo [" + getClass().getSimpleName() + ".insertGoodsMemoInfo()] memo : " + memo);
            logger.info("[" + request.getRemoteAddr() + "] ====== /insertGoodsMemoInfo [" + getClass().getSimpleName() + ".insertGoodsMemoInfo()] uid : " + uid);


            int rtn = -1;

            rtn = supportService.insertGoodsMemoInfo(brandCode, goodsCode, optionCode, memo, uid);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /insertGoodsMemoInfo [" + getClass().getSimpleName() + ".insertGoodsMemoInfo()] end ======");
    }

    @ApiOperation(value = "상품 메모 삭제", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping("/deleteGoodsMemoInfo")
    public void deleteGoodsMemoInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /deleteGoodsMemoInfo [" + getClass().getSimpleName() + ".deleteGoodsMemoInfo()] start ======");
        try {
            String seq = Utils.checkNull(request.getParameter("seq"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /deleteGoodsMemoInfo [" + getClass().getSimpleName() + ".deleteGoodsMemoInfo()] seq : " + seq);


            int rtn = -1;

            rtn = supportService.deleteGoodsMemoInfo(seq);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /deleteGoodsMemoInfo [" + getClass().getSimpleName() + ".deleteGoodsMemoInfo()] end ======");
    }

    @ApiOperation(value = "상품 메모 수정", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping("/editGoodsMemoInfo")
    public void editGoodsMemoInfo(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /editGoodsMemoInfo [" + getClass().getSimpleName() + ".editGoodsMemoInfo()] start ======");
        try {
            String seq = Utils.checkNull(request.getParameter("seq"));
            String memo = Utils.checkNull(request.getParameter("memo"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /editGoodsMemoInfo [" + getClass().getSimpleName() + ".editGoodsMemoInfo()] seq : " + seq);
            logger.info("[" + request.getRemoteAddr() + "] ====== /editGoodsMemoInfo [" + getClass().getSimpleName() + ".editGoodsMemoInfo()] memo : " + memo);


            int rtn = -1;

            rtn = supportService.editGoodsMemoInfo(seq, memo);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(rtn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /editGoodsMemoInfo [" + getClass().getSimpleName() + ".editGoodsMemoInfo()] end ======");
    }

    @ApiOperation(value = "해당 상품 주문 내용 수집", httpMethod = "POST", notes = "Len.Yun")
    @RequestMapping("/searchGoodsOrder")
    public void searchGoodsOrder(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /searchGoodsOrder [" + getClass().getSimpleName() + ".searchGoodsOrder()] start ======");
        try {
            String brandCode = Utils.checkNull(request.getParameter("brandCode"));
            String goodsCode = Utils.checkNull(request.getParameter("goodsCode"));
            String optionCode = Utils.checkNull(request.getParameter("optionCode"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /searchGoodsOrder [" + getClass().getSimpleName() + ".searchGoodsOrder()] brandCode : " + brandCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /searchGoodsOrder [" + getClass().getSimpleName() + ".searchGoodsOrder()] goodsCode : " + goodsCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /searchGoodsOrder [" + getClass().getSimpleName() + ".searchGoodsOrder()] optionCode : " + optionCode);

            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            for(SupportVO goodsInfo : supportService.searchGoodsOrder(brandCode, goodsCode, optionCode)) {
                JSONObject obj = new JSONObject();

                obj.put("orderSeq", goodsInfo.getOrder_seq());
                obj.put("orderTitle", goodsInfo.getOrder_title());
                obj.put("orderDate", new SimpleDateFormat("yyyy-MM-dd").format(goodsInfo.getOrder_date()));
                obj.put("partnerName", goodsInfo.getPartner_name());
                obj.put("totalImportEa", goodsInfo.getTotal_import_ea());
                obj.put("importedEa", goodsInfo.getImported_ea());
                obj.put("clearanceConfirmEa", goodsInfo.getClearance_confirm_ea());
                obj.put("saleConfirmEa", goodsInfo.getSale_confirm_ea());
                obj.put("depFlag", goodsInfo.getDep_flag());
                obj.put("arrFlag", goodsInfo.getArr_flag());
                obj.put("ea", goodsInfo.getEa());
                obj.put("vatFlag", goodsInfo.getVat_flag());
                obj.put("buyingPrice", goodsInfo.getBuying_price());
                obj.put("price", Utils.checkNull(goodsInfo.getPrice()));
                obj.put("currency", goodsInfo.getCurrency());
                obj.put("cur2krw", goodsInfo.getCur2krw());

                jsonArray.add(obj);
            }
            json.put("data", jsonArray);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(json);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /searchGoodsOrder [" + getClass().getSimpleName() + ".searchGoodsOrder()] end ======");
    }

    @ApiOperation(value = "상품 검색 그래프", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping("/selectTrafficChart")
    public void selectTrafficChart(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectTrafficChart [" + getClass().getSimpleName() + ".selectTrafficChart()] start ======");
        try {
            String brandCode = Utils.checkNull(request.getParameter("brandCode"));
            String goodsCode = Utils.checkNull(request.getParameter("goodsCode"));
            String optionCode = Utils.checkNull(request.getParameter("optionCode"));
            String startGraphDate = Utils.checkNull(request.getParameter("startGraphDate"));
            String endGraphDate = Utils.checkNull(request.getParameter("endGraphDate"));
            String dayType = Utils.checkNull(request.getParameter("dayType"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectTrafficChart [" + getClass().getSimpleName() + ".selectTrafficChart()] brandCode : " + brandCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectTrafficChart [" + getClass().getSimpleName() + ".selectTrafficChart()] goodsCode : " + goodsCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectTrafficChart [" + getClass().getSimpleName() + ".selectTrafficChart()] optionCode : " + optionCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectTrafficChart [" + getClass().getSimpleName() + ".selectTrafficChart()] startGraphDate : " + startGraphDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectTrafficChart [" + getClass().getSimpleName() + ".selectTrafficChart()] endGraphDate : " + endGraphDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectTrafficChart [" + getClass().getSimpleName() + ".selectTrafficChart()] dayType : " + dayType);

            String chartDateType = "";
            if(dayType.equals("day") ) {
                chartDateType = "%Y-%m-%d";
            } else if (dayType.equals("week")) {
                chartDateType = "%Y-%U";
            } else if (dayType.equals("month")) {
                chartDateType = "%Y-%m";
            }

            JSONObject json = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            for(SupportVO trafficInfo : supportService.selectTrafficChart(brandCode, goodsCode, optionCode, startGraphDate, endGraphDate, chartDateType)) {
                JSONObject obj = new JSONObject();

                obj.put("day", trafficInfo.getDay());
                obj.put("gTrafficCount", trafficInfo.getG_traffic_count());
                obj.put("fTrafficCount", trafficInfo.getF_traffic_count());

                jsonArray.add(obj);
            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(jsonArray);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectTrafficChart [" + getClass().getSimpleName() + ".selectTrafficChart()] end ======");
    }

    @ApiOperation(value = "상품 등급 그래프", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping("/selectGradeGraph")
    public void selectGradeGraph(@ApiIgnore HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectGradeGraph [" + getClass().getSimpleName() + ".selectGradeGraph()] start ======");
        try {
            String brandCode = Utils.checkNull(request.getParameter("brandCode"));
            String goodsCode = Utils.checkNull(request.getParameter("goodsCode"));
            String optionCode = Utils.checkNull(request.getParameter("optionCode"));
            String startGradeDate = Utils.checkNull(request.getParameter("startGradeDate"));
            String endGradeDate = Utils.checkNull(request.getParameter("endGradeDate"));
            String dayGradeType = Utils.checkNull(request.getParameter("dayGradeType"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectGradeGraph [" + getClass().getSimpleName() + ".selectGradeGraph()] brandCode : " + brandCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectGradeGraph [" + getClass().getSimpleName() + ".selectGradeGraph()] goodsCode : " + goodsCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectGradeGraph [" + getClass().getSimpleName() + ".selectGradeGraph()] optionCode : " + optionCode);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectGradeGraph [" + getClass().getSimpleName() + ".selectGradeGraph()] startGradeDate : " + startGradeDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectGradeGraph [" + getClass().getSimpleName() + ".selectGradeGraph()] endGradeDate : " + endGradeDate);
            logger.info("[" + request.getRemoteAddr() + "] ====== /selectGradeGraph [" + getClass().getSimpleName() + ".selectGradeGraph()] dayGradeType : " + dayGradeType);

            String graphDateType = "";
            if(dayGradeType.equals("day") ) {
                graphDateType = "%Y-%m-%d";
            } else if (dayGradeType.equals("week")) {
                graphDateType = "%Y-%U";
            } else if (dayGradeType.equals("month")) {
                graphDateType = "%Y-%m";
            }

            JSONArray jsonArray = new JSONArray();
            for(SupportVO gradeInfo : supportService.selectGradeGraph(brandCode, goodsCode, optionCode, startGradeDate, endGradeDate, graphDateType)) {
                JSONObject obj = new JSONObject();

                obj.put("availableMonth", gradeInfo.getAvailable_month());
                obj.put("day", gradeInfo.getDay());

                jsonArray.add(obj);
            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(jsonArray);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /selectGradeGraph [" + getClass().getSimpleName() + ".selectGradeGraph()] end ======");
    }

    @ApiOperation(value = "다중 메모 엑셀 파싱", httpMethod = "GET", notes = "Len.Yun")
    @RequestMapping(value = "/xlsx2json", method = RequestMethod.POST)
    public void xlsx2json(@ApiIgnore HttpSession session, @ApiIgnore MultipartHttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /xlsx2json [" + getClass().getSimpleName() + ".xlsx2json()] start ======");
        try {
            MultipartFile mf = request.getFile("file");
            int sheetNum = Utils.checkNullByInt(request.getParameter("sheetNum"));
            logger.info("[" + request.getRemoteAddr() + "] ====== /xlsx2json [" + getClass().getSimpleName() + ".xlsx2json()] originalFileName : " + mf.getOriginalFilename());
            logger.info("[" + request.getRemoteAddr() + "] ====== /xlsx2json [" + getClass().getSimpleName() + ".xlsx2json()] sheetNum : " + sheetNum);

            String csv = Utils.xlsx2csv(mf.getInputStream(), sheetNum);

            JSONArray outerArray = new JSONArray();
            for (int i = 0; i < csv.split("\n").length; i++) {
                JSONArray innerArray = new JSONArray();
                for (int j = 0; j < csv.split("\n")[i].split(";").length; j++) {
                    innerArray.add(csv.split("\n")[i].split(";")[j]);
                }
                outerArray.add(innerArray);
            }

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(outerArray);
        } catch (Exception e) {
            e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /erp/xlsx2json [" + getClass().getSimpleName() + ".xlsx2json()] end ======");
    }
}
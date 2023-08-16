import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import springfox.documentation.annotations.ApiIgnore;

import static com.tbnws.gtgear.support.config.SwaggerConfig.RESPONSE_PREFIX;

@ApiImplicitParams({
        @ApiImplicitParam(paramType = "form", name = "file", value = "XLSX 파일", dataType = "file"),
        @ApiImplicitParam(paramType = "form", name = "sheetNum", value = "시트 번호")
})
@ApiResponses({
        @ApiResponse(code = 200, message = RESPONSE_PREFIX + "JSONArray" note="Len.Yun")
})
@RequestMapping(value = "/erp/xlsx2json", method = RequestMethod.POST)
public void xlsx2json(@ApiIgnore HttpSession session, @ApiIgnore MultipartHttpServletRequest request, HttpServletResponse response, Model model) {
        logger.info("[" + request.getRemoteAddr() + "] ====== /erp/xlsx2json [" + getClass().getSimpleName() + ".xlsx2json()] start ======");
        try {
        MultipartFile mf = request.getFile("file");
        int sheetNum = Utils.checkNullByInt(request.getParameter("sheetNum"));
        logger.info("[" + request.getRemoteAddr() + "] ====== /erp/xlsx2json [" + getClass().getSimpleName() + ".xlsx2json()] originalFileName : " + mf.getOriginalFilename());
        logger.info("[" + request.getRemoteAddr() + "] ====== /erp/xlsx2json [" + getClass().getSimpleName() + ".xlsx2json()] sheetNum : " + sheetNum);

        String csv = Utils.xlsx2csv(mf.getInputStream(), sheetNum);
//            logger.info("[" + request.getRemoteAddr() + "] ====== /erp/xlsx2json [" + getClass().getSimpleName() + ".xlsx2json()] csv : ");
//            logger.info(csv);

        JSONArray outerArray = new JSONArray();
        for (int i = 0; i < csv.split("\n").length; i++) {
        JSONArray innerArray = new JSONArray();
        for (int j = 0; j < csv.split("\n")[i].split(";").length; j++) {
        innerArray.add(csv.split("\n")[i].split(";")[j]);
        }
        outerArray.add(innerArray);
        }
//            logger.info("[" + request.getRemoteAddr() + "] ====== /erp/xlsx2json [" + getClass().getSimpleName() + ".xlsx2json()] csv to json : ");
//            logger.info(outerArray.toJSONString());

        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().print(outerArray);
        } catch (Exception e) {
        e.printStackTrace();
        }
        logger.info("[" + request.getRemoteAddr() + "] ====== /erp/xlsx2json [" + getClass().getSimpleName() + ".xlsx2json()] end ======");
        }
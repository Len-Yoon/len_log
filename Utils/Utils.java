package com.tbnws.gtgear.support.Util;

import com.google.gson.Gson;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.tomcat.util.codec.binary.Base64;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.http.HttpServletRequest;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.spec.AlgorithmParameterSpec;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class Utils {

    private static Logger logger = LoggerFactory.getLogger(Utils.class);

    public static final String KEY_128 = "!to_be_networks@";
    public static final String KEY_256 = "!!to__be__networks__sidebyside@@";

    public static byte[] ivBytes = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};


    public static boolean isValidMD5(String s) {
        return s.matches("^[a-fA-F0-9]{32}$");
    }

    public static String shortUrl(String url) {
        String shortUrl = "";
        String apiURL = "http://gtg.kr/yourls-api.php";
        apiURL += "?username=root";
        apiURL += "&password=dnpfzja!";
        apiURL += "&format=json";
        apiURL += "&action=shorturl";
        apiURL += "&url=" + url;

        try {
            JSONObject response = (JSONObject) new JSONParser().parse(Utils.httpGet(apiURL, false));
            logger.info("response = " + response.toString());
            if (Integer.parseInt(response.get("statusCode").toString()) == 200) {
                shortUrl = response.get("shorturl").toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return shortUrl;
    }

    public static String shortUrlPost(String url, String title) {
        String shortUrl = "";
        try {
            HashMap<String, Object> params = new HashMap<>();
            params.put("username", "root");
            params.put("password","dnpfzja!");
            params.put("action","shorturl");
            params.put("format","json");
            params.put("title",URLEncoder.encode(title, "UTF-8"));
            params.put("url",URLEncoder.encode(url, "UTF-8"));
            JSONObject response = (JSONObject) new JSONParser().parse(Utils.httpPost("http://gtg.kr/yourls-api.php",null,params,false));

            if (Integer.parseInt(response.get("statusCode").toString()) == 200 && response.get("status").toString().equals("success")) {
                shortUrl = response.get("shorturl").toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return shortUrl;
    }

    public static JSONObject yourlsAPI(HashMap<String, Object> yourlsParams) {
        JSONObject response = new JSONObject();
        try {
            /* 210106. KimGoon. passwordless -> username/password
            String apiURL = "http://gtg.kr/yourls-api.php?signature=a872b1348e&format=json";
            */
            String apiURL = "http://gtg.kr/yourls-api.php";
            apiURL += "?username=root";
            apiURL += "&password=dnpfzja!";
            apiURL += "&format=json";

            if (yourlsParams != null) {
                for (Iterator it = yourlsParams.keySet().iterator(); it.hasNext(); ) {
                    String key = (String) it.next();
                    String value = (String) yourlsParams.get(key);

                    apiURL += "&" + key + "=" + value;
                }
            }

            response = (JSONObject) new JSONParser().parse(Utils.httpGet(apiURL, false));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return response;
    }

    public static String md5(String str) {
        String md5 = "";

        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(str.getBytes());
            byte[] byteData = md.digest();
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < byteData.length; i++) {
                sb.append(Integer.toString((byteData[i] & 0xff) + 0x100, 16).substring(1));
            }
            md5 = sb.toString();

        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            md5 = null;
        }

        return md5;
    }

    public static String sendMMS(String categoryCode, String recvNum, String title, String content, String tag) {
        String response = "";
        try {
            /*
            HashMap<String, Object> params = new HashMap<>();

            params.put("cKey", categoryCode);
            params.put("recvNum", recvNum);
            params.put("subject", URLEncoder.encode(subject, "UTF-8"));
            params.put("body", URLEncoder.encode(body, "UTF-8"));
            params.put("type", type);

            response = Utils.httpPost("http://localhost:8081/api/sendMMS", null, params);
            */

            HashMap<String, Object> params = new HashMap<>();
            params.put("senderCode", categoryCode);
            params.put("recvNum", recvNum);
            params.put("title", URLEncoder.encode(title, "UTF-8"));
            params.put("content", URLEncoder.encode(content, "UTF-8"));
            params.put("tag", tag);
            response = Utils.httpPost("https://pys.tbnws.com/sms/send", null, params, false);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return response;
    }

    public static String sendEmail(String senderCode, String recvEmail, String title, String content, String tag, JSONObject reference) {
        String response = "";
        try {
            HashMap<String, Object> params = new HashMap<>();
            params.put("senderCode", senderCode);
            params.put("recvEmail", recvEmail);
            params.put("title", URLEncoder.encode(title, "UTF-8"));
            params.put("content", URLEncoder.encode(content, "UTF-8"));
            params.put("tag", tag);
            if (reference != null) {
                params.put("reference", new Gson().toJson(reference));
            }
            response = Utils.httpPost("https://pys.tbnws.com/email/send", null, params, false);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return response;
    }

    public static void uploadFileFTP(String filePath, File file) {
        try {
            FTPUtil ftpUtil = new FTPUtil();
            ftpUtil.init();
            ftpUtil.mkdir(filePath);
            ftpUtil.upload(filePath, file);
            ftpUtil.disconnect();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String getRemoteIP(HttpServletRequest request) {
        String remoteIP = request.getHeader("X-FORWARDED-FOR");

        if (remoteIP == null || remoteIP.length() == 0) {
            remoteIP = request.getRemoteAddr();
        }

        return remoteIP;
    }

    public static String xlsx2csv(InputStream is, int sheetNum) {
        String csv = "";

        Workbook wb = null;
        try {
            wb = WorkbookFactory.create(is);

            for (int i = 0; i <= wb.getSheetAt(sheetNum).getLastRowNum(); i++) {
                Row row = wb.getSheetAt(sheetNum).getRow(i);
                if (row != null) {
                    for (int j = 0; j < row.getLastCellNum(); j++) {
                        if (row.getCell(j) != null) {
                            String rowCell = "";
                            if (row.getCell(j).getCellType() == Cell.CELL_TYPE_NUMERIC) {
                                if (DateUtil.isCellDateFormatted(row.getCell(j))) {
                                    Date date = row.getCell(j).getDateCellValue();
                                    rowCell = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(date);
                                }
                                else if(Math.rint(row.getCell(j).getNumericCellValue()) != row.getCell(j).getNumericCellValue()) {
                                    rowCell = Double.toString(row.getCell(j).getNumericCellValue());
                                }
                                else {
                                    rowCell = Long.toString((long) row.getCell(j).getNumericCellValue());
                                }
                            } else if (row.getCell(j).getCellType() == Cell.CELL_TYPE_BOOLEAN) {
                                rowCell = row.getCell(j).getBooleanCellValue() == true ? "TRUE" : "FALSE";
                            } else {
                                rowCell = row.getCell(j).getStringCellValue();
                            }
                            csv += rowCell.replaceAll("\n", "").replaceAll("\t", "").replaceAll("&amp;", "&");
                        }

                        if (j != row.getLastCellNum() - 1) {
                            csv += ";";
                        }
                    }
                    csv += "\n";
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InvalidFormatException e) {
            e.printStackTrace();
        } finally {
            try {
                is.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return csv;
    }


    /**
     * <PRE>
     * 1. MethodName: Utils.filterPhoneNo()
     * 2. Comment   :
     * </PRE>
     *
     * @param phoneNo
     * @return String
     */
    public static String filterPhoneNo(String phoneNo) {

        return phoneNo.replace("-", "").replace(".", "").replace(" ", "");
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.checkEmpty()
     * 2. Comment   :
     * </PRE>
     *
     * @param str
     * @return String
     */
    public static String checkEmpty(String str, String rtn) {

        if (str == null || str.equals(""))
            return rtn;
        else
            return str;
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.checkNull()
     * 2. Comment   :
     * </PRE>
     *
     * @param str
     * @return String
     */
    public static String checkNull(String str) {

        if (str == null)
            return "";
        else
            return str;
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.checkNullbyInt()
     * 2. Comment   :
     * </PRE>
     *
     * @param str
     * @return int
     */
    public static int checkNullByInt(String str) {

        if (str == null || str.equals(""))
            return 0;
        else
            return Integer.parseInt(str);
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.checkNullByDouble()
     * 2. Comment   :
     * </PRE>
     *
     * @param str
     * @return double
     */
    public static double checkNullByDouble(String str) {

        if (str == null || str.equals(""))
            return 0.0;
        else
            return Double.parseDouble(str);
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.isEmpty()
     * 2. Comment	:
     * </PRE>
     *
     * @param str
     * @return boolean
     */
    public static boolean isEmpty(String str) {

        return str == null || str.equals("");
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.isNotEmpty()
     * 2. Comment	:
     * </PRE>
     *
     * @param str
     * @return boolean
     */
    public static boolean isNotEmpty(String str) {

        return str != null && !str.equals("");
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.isNumber()
     * 2. Comment   :
     * </PRE>
     *
     * @param str
     * @return boolean
     */
    public static boolean isNumber(String str) {

        try {
            Double.parseDouble(str);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static boolean isFloat(String str) {

        try {
            Double.parseDouble(str);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.sha256()
     * 2. Comment   :
     * </PRE>
     *
     * @param str
     * @return String
     */
    public static String sha256(String str) {

        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(str.getBytes());
            byte[] byteData = md.digest();
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < byteData.length; i++) {
                sb.append(Integer.toString((byteData[i] & 0xff) + 0x100, 16).substring(1));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.sha512()
     * 2. Comment	:
     * </PRE>
     *
     * @param str
     * @return String
     */
    public static String sha512(String str) {

        try {
            MessageDigest md = MessageDigest.getInstance("SHA-512");
            md.update(str.getBytes());
            byte[] byteData = md.digest();
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < byteData.length; i++) {
                String s = Integer.toHexString(byteData[i] & 0xff);
                while (s.length() < 2) {
                    s = "0" + s;
                }
                sb.append(s.substring(s.length() - 2));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.encryptAES128()
     * 2. Comment   :
     * </PRE>
     *
     * @param plainText
     * @return String
     */
    public static String encryptAES128(String plainText) {

        try {
            byte[] textBytes = plainText.getBytes(StandardCharsets.UTF_8);

            AlgorithmParameterSpec ivSpec = new IvParameterSpec(ivBytes);
            SecretKeySpec newKey = new SecretKeySpec(KEY_128.getBytes(StandardCharsets.UTF_8), "AES");
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            cipher.init(Cipher.ENCRYPT_MODE, newKey, ivSpec);

            return Base64.encodeBase64String(cipher.doFinal(textBytes));
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.decryptAES128()
     * 2. Comment   :
     * </PRE>
     *
     * @param encryptedData
     * @return String
     */
    public static String decryptAES128(String encryptedData) {

        try {
            byte[] textBytes = Base64.decodeBase64(encryptedData);

            AlgorithmParameterSpec ivSpec = new IvParameterSpec(ivBytes);
            SecretKeySpec newKey = new SecretKeySpec(KEY_128.getBytes(StandardCharsets.UTF_8), "AES");
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            cipher.init(Cipher.DECRYPT_MODE, newKey, ivSpec);

            return new String(cipher.doFinal(textBytes), StandardCharsets.UTF_8);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.encryptAES256()
     * 2. Comment   :
     * </PRE>
     *
     * @param plainText
     * @return String
     */
    public static String encryptAES256(String plainText) {

        try {
            byte[] textBytes = plainText.getBytes(StandardCharsets.UTF_8);

            AlgorithmParameterSpec ivSpec = new IvParameterSpec(ivBytes);
            SecretKeySpec newKey = new SecretKeySpec(KEY_256.getBytes(StandardCharsets.UTF_8), "AES");
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            cipher.init(Cipher.ENCRYPT_MODE, newKey, ivSpec);

            return Base64.encodeBase64String(cipher.doFinal(textBytes));
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.decryptAES256()
     * 2. Comment   :
     * </PRE>
     *
     * @param encryptedData
     * @return String
     */
    public static String decryptAES256(String encryptedData) {

        try {
            byte[] textBytes = Base64.decodeBase64(encryptedData);

            AlgorithmParameterSpec ivSpec = new IvParameterSpec(ivBytes);
            SecretKeySpec newKey = new SecretKeySpec(KEY_256.getBytes(StandardCharsets.UTF_8), "AES");
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            cipher.init(Cipher.DECRYPT_MODE, newKey, ivSpec);

            return new String(cipher.doFinal(textBytes), StandardCharsets.UTF_8);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // 암호화
    public static String aesEncode(String str, String key) {

        try {
            key = new String(Base64.decodeBase64(key));
            byte[] keyBytes = new byte[16];
            byte[] b = key.getBytes(StandardCharsets.UTF_8);
            int len = b.length;
            if (len > keyBytes.length)
                len = keyBytes.length;
            System.arraycopy(b, 0, keyBytes, 0, len);

            AlgorithmParameterSpec ivSpec = new IvParameterSpec(key.substring(0, 16).getBytes());
            SecretKeySpec newKey = new SecretKeySpec(keyBytes, "AES");
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            cipher.init(Cipher.ENCRYPT_MODE, newKey, ivSpec);

            byte[] encrypted = cipher.doFinal(str.getBytes(StandardCharsets.UTF_8));
            String enStr = new String(Base64.encodeBase64(encrypted));

            return enStr;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    //복호화
    public static String aesDecode(String str, String key) {

        try {
            key = new String(Base64.decodeBase64(key));
            byte[] keyBytes = new byte[16];
            byte[] b = key.getBytes(StandardCharsets.UTF_8);
            int len = b.length;
            if (len > keyBytes.length)
                len = keyBytes.length;
            System.arraycopy(b, 0, keyBytes, 0, len);

            AlgorithmParameterSpec ivSpec = new IvParameterSpec(key.substring(0, 16).getBytes());
            SecretKeySpec newKey = new SecretKeySpec(keyBytes, "AES");
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            cipher.init(Cipher.DECRYPT_MODE, newKey, ivSpec);

            byte[] byteStr = Base64.decodeBase64(str.getBytes());

            return new String(cipher.doFinal(byteStr), StandardCharsets.UTF_8);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.hexToByteArray()
     * 2. Comment   : hex to byte[] : 16진수 문자열을 바이트 배열로 변환한다.
     * </PRE>
     *
     * @param hex
     * @return
     */
    public static byte[] hexToByteArray(String hex) {

        if (hex == null || hex.length() == 0) {
            return null;
        }

        byte[] ba = new byte[hex.length() / 2];

        for (int i = 0; i < ba.length; i++) {
            ba[i] = (byte) Integer.parseInt(hex.substring(2 * i, 2 * i + 2), 16);
        }

        return ba;
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.byteArrayToHex()
     * 2. Comment   : unsigned byte(바이트) 배열을 16진수 문자열로 바꾼다.
     * </PRE>
     *
     * @param ba
     * @return
     */
    public static String byteArrayToHex(byte[] ba) {

        if (ba == null || ba.length == 0) {
            return null;
        }

        StringBuffer sb = new StringBuffer(ba.length * 2);
        String hexNumber;

        for (int x = 0; x < ba.length; x++) {
            hexNumber = "0" + Integer.toHexString(0xff & ba[x]);
            sb.append(hexNumber.substring(hexNumber.length() - 2));
        }

        return sb.toString();
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.getTimeInMillis()
     * 2. Comment   :
     * </PRE>
     *
     * @param year
     * @param month
     * @param date
     * @param hour
     * @param minute
     * @param second
     * @return long
     */
    public static long getTimeInMillis(int year, int month, int date, int hour, int minute, int second) {

        Calendar calendar = Calendar.getInstance();
        calendar.set(year, month - 1, date, hour, minute, second);
        return calendar.getTime().getTime();
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.getTimeInMillis()
     * 2. Comment   : YYYYMMDDHH24MISS -> sec
     * </PRE>
     *
     * @param timeString
     * @return long
     */
    public static long getTimeInMillis(String timeString) {

        if (timeString == null || timeString.length() < 14)
            return 0;
        int year = Integer.parseInt(timeString.substring(0, 4));
        int month = Integer.parseInt(timeString.substring(4, 6));
        int date = Integer.parseInt(timeString.substring(6, 8));
        int hour = Integer.parseInt(timeString.substring(8, 10));
        int minute = Integer.parseInt(timeString.substring(10, 12));
        int second = Integer.parseInt(timeString.substring(12, 14));

        return getTimeInMillis(year, month, date, hour, minute, second);
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.getYYYYMMDDHHMMSSInString()
     * 2. Comment   : sec -> YYYYMMDDHH24MISS
     * </PRE>
     *
     * @param timeStamp
     * @return String
     */
    public static String getYYYYMMDDHHMMSSInString(long timeStamp) {

        StringBuffer buffer = new StringBuffer();
        Calendar calendar = Calendar.getInstance();
        Date trialTime = new Date(timeStamp);
        calendar.setTime(trialTime);
        buffer.append(getZeroString(calendar.get(Calendar.YEAR), 4));
        buffer.append(getZeroString(calendar.get(Calendar.MONTH) + 1, 2));
        buffer.append(getZeroString(calendar.get(Calendar.DATE), 2));
        buffer.append(getZeroString(calendar.get(Calendar.HOUR_OF_DAY), 2));
        buffer.append(getZeroString(calendar.get(Calendar.MINUTE), 2));
        buffer.append(getZeroString(calendar.get(Calendar.SECOND), 2));

        return buffer.toString();
    }

    /**
     * <PRE>
     * 1. MethodName: Utils.getInitTimeInMillis()
     * 2. Comment   : YYYYMMDDHH24MI -> sec
     * </PRE>
     *
     * @param timeString
     * @return
     */
    public static long getInitTimeInMillis(String timeString) {

        if (timeString == null || timeString.length() < 14)
            return 0;
        int year = Integer.parseInt(timeString.substring(0, 4));
        int month = Integer.parseInt(timeString.substring(4, 6));
        int date = Integer.parseInt(timeString.substring(6, 8));
        int hour = Integer.parseInt(timeString.substring(8, 10));
        int minute = Integer.parseInt(timeString.substring(10, 12));
        int second = 00;

        return getTimeInMillis(year, month, date, hour, minute, second);
    }

    public static String getZeroString(int i, int len) {

        String s = Integer.toString(i);
        int gap = len - s.length();

        for (int j = 0; j < gap; j++)
            s = "0" + s;

        return s;
    }

    public static void copyFile(File orgFile, File newFile) {

        File[] fileList = orgFile.listFiles();
        for (File f : fileList) {
            File tmp = new File(newFile.getAbsolutePath() + File.separator + f.getName());
            logger.info("moveFile : " + tmp.getAbsolutePath());

            if (f.isDirectory()) {
                tmp.mkdirs();
                copyFile(f, tmp);
            } else {
                FileInputStream fis = null;
                FileOutputStream fos = null;
                try {
                    fis = new FileInputStream(f);
                    fos = new FileOutputStream(tmp);
                    byte[] b = new byte[4096];
                    int cnt = 0;

                    while ((cnt = fis.read(b)) != -1) {
                        fos.write(b, 0, cnt);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (fis != null) fis.close();
                        if (fos != null) fos.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    public static void moveFile(File orgFile, File newFile) {

        File[] fileList = orgFile.listFiles();
        for (File f : fileList) {
            File tmp = new File(newFile.getAbsolutePath() + File.separator + f.getName());
            logger.info("moveFile : " + f.getAbsolutePath() + " -> " + tmp.getAbsolutePath());

            if (f.isDirectory()) {
                tmp.mkdirs();
                moveFile(f, tmp);
            } else {
                if (f.exists()) {
                    f.renameTo(tmp);
                }
            }
        }
    }

    public static void deleteFile(File file) {

        if (file.exists()) {
            if (file.isDirectory()) {
                File[] fileList = file.listFiles();
                if (fileList != null && fileList.length > 0) {
                    for (File f : fileList) {
                        deleteFile(f);
                    }
                }
            }
            logger.info("deleteFile : " + file.getAbsolutePath());
            file.delete();
        }
    }

    public static void unzipFile(String fileGbn, File file) {

        File zipFile = new File(file.getAbsolutePath());
        FileInputStream fis = null;
        ZipInputStream zis = null;
        ZipEntry zipEntry = null;

        try {
            fis = new FileInputStream(zipFile);
            zis = new ZipInputStream(fis);

            while ((zipEntry = zis.getNextEntry()) != null) {
                String fileName = zipEntry.getName();
                logger.info("unzipFile : " + fileName);
                File f = new File(file.getParent() + File.separator + fileGbn, fileName);

                if (zipEntry.isDirectory()) {
                    f.mkdirs();
                } else {
                    File parentDir = new File(f.getParent());
                    if (!parentDir.exists()) {
                        parentDir.mkdirs();
                    }

                    try {
                        FileOutputStream fos = new FileOutputStream(f);
                        byte[] buffer = new byte[256];
                        int size = 0;
                        while ((size = zis.read(buffer)) > 0) {
                            fos.write(buffer, 0, size);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (zis != null) zis.close();
                if (fis != null) fis.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public static String xlsParser(String filePath) {

        String content = "";

        try {
            FileInputStream fis = new FileInputStream(filePath);
            HSSFWorkbook workbook = new HSSFWorkbook(fis);

            for (int sheetIdx = 0; sheetIdx < workbook.getNumberOfSheets(); sheetIdx++) {

//                HSSFSheet sheet = workbook.getSheetAt(0);
                HSSFSheet sheet = workbook.getSheetAt(sheetIdx);

                for (int rowIdx = sheet.getFirstRowNum(); rowIdx <= sheet.getLastRowNum(); rowIdx++) {

                    Row row = sheet.getRow(rowIdx);
                    if (row == null)
                        continue;

                    String contentName = row.getCell(0).getRichStringCellValue().getString();
                    String serial = row.getCell(1).getRichStringCellValue().getString();

                    if (Utils.isEmpty(contentName))
                        continue;

                    content += contentName + "^" + serial + "|";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        logger.info(content);
        return content;
    }

    public static String xlsxParser(String filePath) {

        String content = "";

        try {
            FileInputStream fis = new FileInputStream(filePath);
            XSSFWorkbook workbook = new XSSFWorkbook(fis);

            for (int sheetIdx = 0; sheetIdx < workbook.getNumberOfSheets(); sheetIdx++) {

//                XSSFSheet sheet = workbook.getSheetAt(0);
                XSSFSheet sheet = workbook.getSheetAt(sheetIdx);

                for (int rowIdx = sheet.getFirstRowNum(); rowIdx <= sheet.getLastRowNum(); rowIdx++) {

                    Row row = sheet.getRow(rowIdx);
                    if (row == null)
                        continue;

                    String contentName = row.getCell(0).getRichStringCellValue().getString();
                    String serial = row.getCell(1).getRichStringCellValue().getString();

                    if (Utils.isEmpty(contentName))
                        continue;

                    content += contentName + "^" + serial + "|";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        logger.info(content);
        return content;
    }

    public static boolean sendMail(String address, String password, String from, String to, String subject, String body) {
        return sendMail(address, password, from, "", to, subject, body);
    }

    public static boolean sendMail(String address, String password, String from, String personal, String to, String subject, String body) {

        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", "smtp.gmail.com");  // SMTP Host
            props.put("mail.smtp.socketFactory.port", "465");   // SSL Port
            props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");   // SSL Factory Class
            props.put("mail.smtp.auth", "true");    // Enabling SMTP Authentication
            props.put("mail.smtp.port", "465"); // SMTP Port

            Authenticator auth = new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(address, password);
                }
            };

            Session mailSession = Session.getInstance(props, auth);
            MimeMessage msg = new MimeMessage(mailSession);
            msg.addHeader("Content-type", "text/HTML; charset=UTF-8");
            msg.addHeader("format", "flowed");
            msg.addHeader("Content-Transfer-Encoding", "8bit");

            msg.setFrom(new InternetAddress(from, personal, "UTF-8"));
            msg.setSentDate(new Date());
            msg.setSubject(subject, "UTF-8");
            msg.setContent(body, "text/html; charset=utf-8");

            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to, false)); // TO : 받는사람, CC : 참조, BCC : 숨은참조

            Transport.send(msg);
            logger.info("Email Send Complete : " + to);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        return true;
    }

    public static String httpGet(String getURL) throws Exception {
        return httpGet(getURL, null, true);
    }

    public static String httpGet(String getURL, boolean resLog) throws Exception {
        return httpGet(getURL, null, resLog);
    }

    public static String httpGet(String getURL, HashMap<String, Object> header, boolean resLog) throws Exception {
        logger.info("====== httpGet()] getURL : " + getURL);

        URL url = new URL(getURL);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("GET");
        con.setRequestProperty("Accept-Charset", "UTF-8");
        con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

        if (header != null) {
            for (Iterator it = header.keySet().iterator(); it.hasNext(); ) {
                String key = (String) it.next();
                String value = (String) header.get(key);
                con.setRequestProperty(key, value);
            }
        }

        int responseCode = con.getResponseCode();
        logger.info("====== httpGet()] responseCode : " + responseCode);

        if (responseCode != 200)
            return null;

        BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream()));
        String inputLine;
        StringBuffer res = new StringBuffer();
        while ((inputLine = br.readLine()) != null) {
            res.append(inputLine);
        }
        br.close();

        String rtn = res.toString();
        if (resLog)
            logger.info("====== httpGet()] res.toString() : " + rtn);

        return rtn;
    }

    public static String httpGet(String getURL, HashMap<String, Object> header, HashMap<String, Object> param) throws Exception {
        logger.info("====== httpGet()] getURL : " + getURL);

        URL url = new URL(getURL);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("GET");
        con.setRequestProperty("Accept-Charset", "UTF-8");
        con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

        if (header != null) {
            for (Iterator it = header.keySet().iterator(); it.hasNext(); ) {
                String key = (String) it.next();
                String value = (String) header.get(key);
                con.setRequestProperty(key, value);
            }
        }

        StringBuffer sb = new StringBuffer();
        if (param != null) {
            for (Iterator it = param.keySet().iterator(); it.hasNext(); ) {
                String key = (String) it.next();
                String value = (String) param.get(key);
                sb.append(key).append("=").append(value).append("&");
            }
            sb.deleteCharAt(sb.length() - 1);
                logger.info("====== httpGet()] param : " + sb.toString());
        }

        int responseCode = con.getResponseCode();
        logger.info("====== httpGet()] responseCode : " + responseCode);

        if (responseCode != 200)
            return null;

        return "200";
    }

    public static String httpPost(String getURL, HashMap<String, Object> header, HashMap<String, Object> param) throws Exception {
        return httpPost(getURL, header, param, true);
    }

    public static String httpPost(String getURL, HashMap<String, Object> header, HashMap<String, Object> param, boolean logFlag) throws Exception {
        // "&"를 특수문자 "＆" 로 치환
        // "%"를 특수문자 "％" 로 치환
        if (getURL.endsWith("/line/notify") && !param.getOrDefault("message", "").toString().isEmpty()) {
            param.put("message", param.get("message").toString()
                    .replaceAll("&", "＆")
                    .replaceAll("%", "％")
            );
        }
        logger.info("====== httpPost()] getURL : " + getURL);

        URL url = new URL(getURL);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setDoOutput(true);
        con.setInstanceFollowRedirects(false);
        con.setRequestProperty("Accept-Charset", "UTF-8");
        con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

        if (header != null) {
            for (Iterator it = header.keySet().iterator(); it.hasNext(); ) {
                String key = (String) it.next();
                String value = (String) header.get(key);
                con.setRequestProperty(key, value);
            }
            if (logFlag)
                logger.info("====== httpPost()] header : " + header.toString());
        }

        StringBuffer sb = new StringBuffer();
        if (param != null) {
            for (Iterator it = param.keySet().iterator(); it.hasNext(); ) {
                String key = (String) it.next();
                String value = (String) param.get(key);
                sb.append(key).append("=").append(value).append("&");
            }
            sb.deleteCharAt(sb.length() - 1);
            if (logFlag)
                logger.info("====== httpPost()] param : " + sb.toString());
        }

        PrintWriter pw = new PrintWriter(new OutputStreamWriter(con.getOutputStream(), StandardCharsets.UTF_8));
        pw.write(sb.toString());
        pw.flush();

        int responseCode = con.getResponseCode();
        logger.info("====== httpPost()] responseCode : " + responseCode);

        if (responseCode != 200)
            return null;

        BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), StandardCharsets.UTF_8));
        String inputLine;
        StringBuffer res = new StringBuffer();
        while ((inputLine = br.readLine()) != null) {
            res.append(inputLine);
        }
        br.close();

        String rtn = res.toString();
        if (logFlag)
            logger.info("====== httpPost()] res.toString() : " + rtn);

        return rtn;
    }

    /**
     * 해당 연도 달의 첫번째 날을 구한다.
     */
    public static Date getFirstDateOfMonth(Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);

        cal.set(cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), cal.getActualMinimum(Calendar.DAY_OF_MONTH));
        return cal.getTime();
    }

    /**
     * 해당 연도 달의 마지막 날을 구한다.
     */
    public static Date getLastDateOfMonth(Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);

        cal.set(cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), cal.getActualMaximum(Calendar.DAY_OF_MONTH));
        return cal.getTime();
    }

    /**
     * 계산된 날을 구한다.
     * YEAR : 연
     * MONTH : 월
     * DAY_OF_YEAR : 일
     * HOUR : 시간
     * MINUTE : 분
     * SECOND : 초
     */
    public static Date getcalculatedDate(String field, int amount) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());

        if (field.toUpperCase().equals("YEAR")) {
            cal.add(Calendar.YEAR, amount);
        } else if (field.toUpperCase().equals("MONTH")) {
            cal.add(Calendar.MONTH, amount);
        } else if (field.toUpperCase().equals("DAY_OF_YEAR")) {
            cal.add(Calendar.DAY_OF_YEAR, amount);
        } else if (field.toUpperCase().equals("HOUR")) {
            cal.add(Calendar.HOUR, amount);
        } else if (field.toUpperCase().equals("MINUTE")) {
            cal.add(Calendar.MINUTE, amount);
        } else if (field.toUpperCase().equals("SECOND")) {
            cal.add(Calendar.SECOND, amount);
        }

        return cal.getTime();
    }

//    public static void main(String args[]) throws Exception {
//        String text = "";
//        logger.info(text);
//        logger.info("sha256 : " + sha256(text));
//        logger.info("sha512 : " + sha512(text));
//        String enc128 = encryptAES128(text);
//        logger.info("enc128 : " + enc128);
//        String dec128 = decryptAES128(enc128);
//        logger.info("dec128 : " + dec128);
//        String enc256 = encryptAES256(text);
//        logger.info("enc256 : " + enc256);
//        String dec256 = decryptAES256(enc256);
//        logger.info("dec256 : " + dec256);
//    }
}

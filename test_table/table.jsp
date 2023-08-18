<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:useBean id="date" class="java.util.Date"/>
<jsp:include page="./head.jsp" flush="false"/>


<%--
<th> table head => 표의 제목
<tr> table row  => 가로줄 만드는 역활
<td> table data => 셀 만드는 역활
--%>

<script>
    var testCheckList = [
        {
            title: '제품확인',
            testList : [
                '제품확인1',
                '제품확인2'
            ]
        },
        {
            title: '고객안내',
            testList: [
                '고객안내1',
                '고객안내2',
                '고객안내3'
            ]
        },
        {
            title: 'A/S 내역',
            testList: [
                ''
            ]
        },
        {
            title: '고객안내2',
            testList: [
                '고객안내1',
                '고객안내2',
                '고객안내3'
            ]
        }
    ]

    function initTestCheckList() {
        $("#test_list_title").empty();

        testCheckList.forEach(testInfo => {
            console.log(testInfo)
            var title = testInfo.title;
            var testList = testInfo.testList;

            for (var i = 0; i < testList.length; i++) {
                var tableTr = document.createElement("tr");

                if((i + 1) == testList.length) {
                    tableTr.setAttribute('data-type', 'lastOfServiceType');
                }

                if (i == 0) {
                    var tableTd = document.createElement('td');
                    var tableInput = document.createElement('input');

                    tableTd.classList.add('text-center');
                    tableTd.classList.add('row-head');
                    tableTd.classList.add('edit-cell');

                    tableTd.setAttribute('rowspan', testList.length);

                    tableInput.value = title;

                    tableTr.append(tableTd);
                    tableTd.append(tableInput);
                }

                var testlistTD = document.createElement('td');
                var testListTA = document.createElement('textarea')

                testlistTD.classList.add('important');
                testlistTD.classList.add('edit-cell');
                testlistTD.setAttribute('colspan', '2');

                testListTA.classList.add('cell-control');
                testListTA.placeholder = '서비스 내역을 입력하세요(최대 두줄).';
                testListTA.setAttribute('rows', '1');
                testListTA.value = testList[i];

                testlistTD.append(testListTA);
                tableTr.append(testlistTD);

                var lastTd = document.createElement('td');
                var lastTdDiv = document.createElement('div');
                var lastTdBtn = document.createElement('button');

                lastTd.classList.add('important');
                lastTd.classList.add('sign-cell');

                lastTdDiv.classList.add('sign-cell__div');

                lastTdBtn.classList.add('sign-cell__sign');

                lastTd.append(lastTdDiv);
                lastTdDiv.append(lastTdBtn);
                tableTr.append(lastTd);

                $('#test_list_table_body').append(tableTr);
            }
        });

        const emptyTr = document.createElement('tr');
        const emptyTd = document.createElement('td');

        emptyTr.classList.add('emptyRow');

        emptyTd.setAttribute('colspan', '4');
        emptyTd.innerText = '\\table spacing';

        emptyTr.append(emptyTd);

        $('#test_list_table_body').append(emptyTr);
    }

    $(window).load(function () {
        initTestCheckList();
    });

    document.ready(function () {

    });
</script>

<style>
    #test_list {width: 100%; height: 100%;}

    .test_list_table {width: 80%; border-spacing: 0; vertical-align: middle; border-collapse: collapse; table-layout: fixed;}
    .test_list_table td { padding: 5px 10px; border: 1px solid #000; color: #000; }

    .textArea {width: 100%; height: 100%}

    .check-test_list_table_head { background: #000; }
    .check-test_list_table_head th { color: #FFF !important; padding: 4px 0; border: 1px solid #000; }

    .test_list_table tr.emptyRow td { visibility: hidden; border: none; font-size: 1px; padding: 2px; }
    .test_list_table td.row-head { background: #EEE; }
    .test_list_table td.edit-cell { padding: 0; }
    .test_list_table td.edit-cell input { padding: 10px; border: none; background: none; width: 100%; height: 100%; text-align: center; }
    .test_list_table textarea { display: block; border: none; resize: none; background: none; width: 100%; padding: 10px; height: 100%; overflow: hidden; }

    .test_list_table tfoot td { padding: 15px; }

    .test_list_table .cell-control.hiding { display: none; }
    .test_list_table .cell-control td { padding: 0; border: none; text-align: end; }
    .test_list_table .cell-control button { border: none; color: #FFF; }
    .test_list_table .cell-control button:hover { filter: brightness(90%); }
    .test_list_table .cell-control button.high { width: 100%; background-color: #0d7eff; }
    .test_list_table .cell-control button.sub { width: 25%; background-color: #ddd; }

    .test_list_table td.sign-cell { padding: 0; }
    .test_list_table div.sign-cell__div { display: flex; flex-flow: row nowrap; }
    .test_list_table div.sign-cell__div button { display: block; border:none; background: none; padding: 10px 0; }
    .test_list_table div.sign-cell__div button.sign-cell__sign { flex: 9; color: #ffffff00; }
    .test_list_table div.sign-cell__div button.cell-control { background-color: #ff4747; flex: 1; color: #FFF; }
    .test_list_table div.sign-cell__div button.cell-control:hover { filter: brightness(90%); }
</style>

<body>
    <div id="test_list">
        <div class="test_list_title">
            <h3>테스트 테이블</h3>
        </div>

        <table class="test_list_table">
            <thead class="test_list_table_head">
            <tr>
                <th></th>
                <th colspan="2" class="text-center">서비스 내역</th>
                <th class="text-center">엔지니어 확인</th>
            </tr>
            </thead>

            <tbody id="test_list_table_body"></tbody>

            <tfoot>
            <tr>
                <td class="text-center">서비스 일자</td>
                <td class="text-center">
                    <input class="textArea" type="date" id="checkList_date"/>
                </td>
                <td class="text-center">고객님 성명</td>
                <td class="text-center textArea" id="checkList_name"></td>
            </tr>
            <tr>
                <td colspan="4">
                    <p>
                        <span>◇ 키크론 엔지니어 준수사항</span><br/>
                        <span>- 서비스 내용에 대해 자체 점검 실시 후 고객님께 안내</span><br/>
                        <span>- 서비스 전/후 제품 정상 작동 여부 반드시 안내</span><br/>
                        <span>- 안내사항 중 변경이 있는 경우 반드시 고객님께 안내</span><br/>
                    </p>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>

</body>
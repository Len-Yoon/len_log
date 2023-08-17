<head>
    <%-- 프로필과 이메일 정보 접근 --%>
    <meta name="google-signin-scope" content="profile email"/>
    <%-- 구글 API키 접근 --%>
    <meta name="google-signin-client_id" content="클라이언트 ID KEY"/>
</head>


<body>
    <div class="g-signin2" data-onsuccess="onSignIn" data-theme="dark"></div>
</body>


<script>
    <%-- Ajax 이용한 구글 로그인  --%>
    $.ajax({
        url: 'googleSignIn',
        method: 'POST',
        data: {
            uid: "userId",
            name: "userName",
            email: "userMail"
        },
        async: false,
        dataType: 'json',
        success: function (response) {

        },
        error: function () {
            alert("An error occoured!");
        }
    });
</script>
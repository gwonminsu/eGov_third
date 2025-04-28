<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>설문 목록 페이지</title>
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- 설문 리스트 json 가져오는 api 호출 url -->
	<c:url value="/api/survey/list.do" var="surveyListUrl"/>
	<!-- 로그인 페이지 url -->
	<c:url value="/login.do" var="loginUrl"/>
	<!-- 로그아웃 api 호출 url -->
	<c:url value="/api/user/logout.do" var="logoutUrl" />
	<!-- 설문 작성 페이지 url -->
	<c:url value="/surveyForm.do" var="surveyFormUrl"/>
	<!-- 설문 상세 페이지 url -->
	<c:url value="/surveyDetail.do" var="surveyDetailUrl"/>
	
	<!-- 세션에 담긴 사용자 이름을 JS 변수로 -->
	<script>
		// 서버에서 렌더링 시점에 loginUser.userName 이 없으면 빈 문자열로
		var loginUserName = '<c:out value="${sessionScope.loginUser.userName}" default="" />';
		var isAdmin = '<c:out value="${sessionScope.loginUser.role}" default="" />';
		
		// GET아닌 POST로 진입하기
		function postTo(url, params) {
		    // 폼 요소 생성
		    var form = $('<form>').attr({ method: 'POST', action: url });
		    // hidden input으로 파라미터 삽입
		    $.each(params, function(name, value) {
		        $('<input>').attr({ type: 'hidden', name: name, value: value }).appendTo(form);
		    });
		    // body에 붙이고 제출
		    form.appendTo('body').submit();
		}
	</script>
</head>
<body>
    <h2>설문 목록</h2>
    
	<!-- 사용자 로그인 상태 영역 -->
	<div id="userInfo">
		<span id="loginMsg"></span>
		<button type="button" id="btnGoLogin">로그인하러가기</button>
		<button type="button" id="btnLogout">로그아웃</button>
	</div>
	
    <table id="surveyListTbl" border="1">
    	<thead>
	        <tr>
	            <th>Idx</th>
	            <th>작성자</th>
	            <th>수정자idx</th>
	            <th>제목</th>
	            <th>개요</th>
	            <th>설문 시작일</th>
	            <th>설문 종료일</th>
	            <th>사용 유무</th>
	            <th>등록일</th>
	            <th>수정일</th>
	        </tr>
    	</thead>
    	<tbody></tbody>
    </table>
    
    <button type="button" id="btnGoSurveyForm">등록</button>
    
    <script>
	    $(function(){
	    	// 페이지 렌더링 시 사용자 리스트 가져오기
		    $(document).ready(function() {
		    	console.log('AJAX 호출 URL=', '${userListUrl}');
		        $.ajax({
		            url: '${surveyListUrl}',
		            type: 'POST',
		            dataType: 'json',
		            success: function(data) {
		            	console.log('받아온 데이터=', data);
		                var $tbody = $('#surveyListTbl').find('tbody');
		                $tbody.empty();
		                $.each(data, function(i, item) {
		                    var row = '<tr>' +
		                              '<td>' + item.idx + '</td>' +
		                              '<td>' + item.userName + '</td>' +
		                              '<td>' + item.editorIdx + '</td>' +
		                              '<td>' + item.title + '</td>' +
		                              '<td>' + item.description + '</td>' +
		                              '<td>' + item.startDate + '</td>' +
		                              '<td>' + item.endDate + '</td>' +
		                              '<td>' + item.isUse + '</td>' +
		                              '<td>' + item.createdAt + '</td>' +
		                              '<td>' + item.updatedAt + '</td>' +
		                              '</tr>';
		                    $tbody.append(row);  
		                });
		            },
		            error: function(xhr, status, error) {
		                console.error('AJAX 에러:', error);
		            }
		        });
		    });
	    	
	        // 로그인 여부에 따라 버튼 토글
	        if (loginUserName) {
				$('#loginMsg').text('현재 로그인 중인 사용자: ' + loginUserName);
				$('#btnGoLogin').hide();
				$('#btnLogout').show();
	        } else {
				$('#welcomeMsg').text('');
				$('#btnGoLogin').show();
				$('#btnLogout').hide();
	        }
	        
	        // 관리자면 설문 등록 표시
	        if (isAdmin) {
	        	$('#btnGoSurveyForm').show();
	        } else {
	        	$('#btnGoSurveyForm').hide();
	        }
	    	
	    	// 로그인 버튼 핸들러
	    	$('#btnGoLogin').click(function() {
	    		// 로그인 페이지 이동
	    		postTo('${loginUrl}', {});
	    	});
	    	
	        // 로그아웃
	        $('#btnLogout').click(function(){
				$.ajax({
					url: '${logoutUrl}',
					type: 'POST',
					success: function(){
						location.reload();
					},
					error: function(){
						alert('로그아웃 중 오류 발생');
					}
				});
	        });
	        
	        // 설문 등록 버튼 핸들러
	        $('#btnGoSurveyForm').click(function() {
	        	// 설문 등록 페이지로 이동
				postTo('${surveyFormUrl}', {});
			})
	        
	    });
    </script>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>설문 통계</title>
	<link rel="stylesheet" href="<c:url value='/css/surveyStats.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- API URL -->
	<c:url value="/api/survey/detail.do" var="detailApi"/>
	<c:url value="/api/survey/questions.do" var="questionsApi"/>
	
	<!-- 설문관리(목록) 페이지 URL -->
	<c:url value="/surveyManage.do" var="surveyManageUrl"/>
	
	<script>
		var sessionUserIdx = '<c:out value="${sessionScope.loginUser.idx}" default="" />';
	
	    // 검색 변수(파라미터에서 값 받아와서 검색 상태 유지)
		var currentSearchType = '<c:out value="${param.searchType}" default="title"/>';
		var currentSearchKeyword = '<c:out value="${param.searchKeyword}" default=""/>';
		var currentPageIndex = parseInt('<c:out value="${param.pageIndex}" default="1"/>');
	
        // 동적 POST 폼 생성 함수
        function postTo(url, params) {
            var form = $('<form>').attr({ method: 'POST', action: url });
            $.each(params, function(name, value){
                $('<input>').attr({ type: 'hidden', name: name, value: value }).appendTo(form);
            });
            form.appendTo('body').submit();
        }
	</script>
	
</head>
<body>

	<h2>설문 통계</h2>
	
	<!-- 설문 메타 정보가 들어갈 영역 -->
	<table class="survey-info">
		<tr><th>제목</th><td id="svTitle"></td></tr>
		<tr><th>개요</th><td id="svDesc"></td></tr>
		<tr><th>설문 등록자</th><td id="svAuthor"></td></tr>
		<tr>
			<th>설문 기간</th>
			<td><span id="svStart"></span> ~ <span id="svEnd"></span></td>
		</tr>
	</table>
	
	<!-- 각 질문 통계 정보 렌더링 영역 -->
	<div id="questionStatsInfo"></div>
	
	<div class="btn-area">
		<button type="button" id="btnList">목록</button>
	</div>
	
	<script>
		// URL 파라미터로 전달된 설문 idx
		var idx = '${param.idx}';
		
		// 설문 idx가 파라미터에 없으면
		if (!idx) {
			alert('잘못된 접근입니다');
			postTo('${listUrl}', { searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
		}
	
		$(function(){
			// 설문 기본 정보 조회
			$.ajax({
				url: '${detailApi}',
				type: 'POST',
				contentType: 'application/json',
				data: JSON.stringify({ idx: idx }),
				success: function(sv) {
					$('#svTitle').text(sv.title);
					$('#svDesc').text(sv.description);
					$('#svAuthor').text(sv.userName);
					$('#svStart').text(sv.startDate.substr(0,10));
					$('#svEnd').text(sv.endDate.substr(0,10));
				},
				error: function() {
					alert('설문 정보를 불러올 수 없습니다');
				}
			});

			// 질문 목록 조회
			$.ajax({
				url: '${questionsApi}',
				type: 'POST',
				contentType: 'application/json',
				data: JSON.stringify({ surveyIdx: idx }),
				success: function(list) {
					// 여기에 각 질문에 대한 답변 통계 렌더링을 할 예정
				},
				error: function() {
					alert('질문 목록을 불러올 수 없습니다');
				}
			});

			// 목록 버튼
			$('#btnList').click(function() {
				postTo('${surveyManageUrl}', { searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
			});
		});
	</script>
	
</body>
</html>
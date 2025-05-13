<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>설문 목록 페이지</title>
	<link rel="stylesheet" href="<c:url value='/css/surveyList.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- 설문 리스트 json 가져오는 api 호출 url -->
	<c:url value="/api/survey/list.do" var="surveyListUrl"/>
	<!-- 로그인 페이지 url -->
	<c:url value="/login.do" var="loginUrl"/>
	<!-- 로그아웃 api 호출 url -->
	<c:url value="/api/user/logout.do" var="logoutUrl" />
	<!-- 설문 작성 페이지 url -->
	<c:url value="/surveyManage.do" var="surveyManageUrl"/>
	<!-- 설문 상세 페이지 url -->
	<c:url value="/surveyDetail.do" var="surveyDetailUrl"/>
	
	<!-- 페이지네이션 버튼 이미지 url -->
	<c:url value="/images/egovframework/cmmn/btn_page_pre10.gif" var="firstImgUrl"/>
	<c:url value="/images/egovframework/cmmn/btn_page_pre1.gif"  var="prevImgUrl"/>
	<c:url value="/images/egovframework/cmmn/btn_page_next1.gif" var="nextImgUrl"/>
	<c:url value="/images/egovframework/cmmn/btn_page_next10.gif" var="lastImgUrl"/>
	
	<!-- 세션에 담긴 사용자 이름을 JS 변수로 -->
	<script>
		// 서버에서 렌더링 시점에 loginUser.userName 이 없으면 빈 문자열로
		var loginUserName = '<c:out value="${sessionScope.loginUser.userName}" default="" />';
		var isAdmin = '<c:out value="${sessionScope.loginUser.role}" default="" />';
		
	    var PAGE_SIZE = ${pageSize}; // 한 그룹당 페이지 버튼 개수
	    var PAGE_UNIT = ${pageUnit}; // 한 페이지당 레코드 수
	    var FIRST_IMG_URL = '${firstImgUrl}';
	    var PREV_IMG_URL = '${prevImgUrl}';
	    var NEXT_IMG_URL = '${nextImgUrl}';
	    var LAST_IMG_URL = '${lastImgUrl}';
	    
	    // 검색 변수(파라미터에서 값 받아와서 검색 상태 유지)
		var currentSearchType = '<c:out value="${param.searchType}" default="title"/>';
		var currentSearchKeyword = '<c:out value="${param.searchKeyword}" default=""/>';
		var currentPageIndex = parseInt('<c:out value="${param.pageIndex}" default="1"/>');
		
		// 에러메시지 알림
		var errorMsg = "${errorMsg}";  
		if (errorMsg) {
			alert(decodeURIComponent(errorMsg)); 
		}
		
		function unescapeHtml(str) {
			return $('<textarea/>').html(str).text();
		}
		
		// AJAX 로 페이징/리스트를 불러오는 함수
		function loadSurveyList(pageIndex) {
			currentPageIndex = pageIndex;
			$('#searchType').val(currentSearchType);
			$('#searchKeyword').val(currentSearchKeyword);
			
		    var sType = $('#searchType').val();
		    var sKeyword = $('#searchKeyword').val().trim();
		    
			var req = {
					pageIndex: currentPageIndex,
					recordCountPerPage: PAGE_UNIT,
					searchType: sType,
					searchKeyword: sKeyword,
					onlyAvailable: true
			};

	        $.ajax({
	            url: '${surveyListUrl}',
	            type: 'POST',
	            contentType: 'application/json',
	            data: JSON.stringify(req),
	            dataType: 'json',
	            success: function(res) {
	            	var data = res.list;
		            var totalCount = res.totalCount;
	            	console.log('받아온 데이터=', data, '총건수=', totalCount);
					// 검색 요약 표시
					if (sType && sKeyword) {
						var label = currentSearchType === 'userName' ? '작성자' : '제목';
						$('#searchInfo').text("[" + sKeyword + "]로 검색된 결과(" + label + ")");
					} else {
						$('#searchInfo').text('');
					}
		            $('.count-red').text(totalCount); // 게시물 수 표시
	                var $tbody = $('#surveyListTbl').find('tbody');
	                $tbody.empty();
	                $.each(data, function(i, item) {
	                	var $tr = $('<tr>');
	                	$tr.append($('<td>').text(item.number));
	                    $tr.append($('<td>').append($('<a>').attr('href', 'javascript:void(0)').text(unescapeHtml(item.title)).on('click', function() {
	                    	postTo('${surveyDetailUrl}', { idx: item.idx, searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
	                    })));
	                    $tr.append($('<td>').text(unescapeHtml(item.description)));
	                    $tr.append($('<td>').text(item.startDate));
	                    $tr.append($('<td>').text(item.endDate));
						$tbody.append($tr);
	                });
	                renderPagination(totalCount, pageIndex);
	            },
	            error: function(xhr, status, error) {
	                console.error('AJAX 에러:', error);
	            }
	        });
		}
		
		// 페이지네이션 UI
		function renderPagination(totalCount, currentPage) {
			var $pg = $('#paginationArea').empty();
			var totalPages = Math.ceil(totalCount / PAGE_UNIT);
			
			// 현재 묶음 인덱스, 시작/끝 페이지 계산
			var groupIndex = Math.floor((currentPage - 1) / PAGE_SIZE);
			var startPage  = groupIndex * PAGE_SIZE + 1;
			var endPage = Math.min(startPage + PAGE_SIZE - 1, totalPages);

			
			// '처음으로' 버튼
			if (currentPage > 1) {
				$pg.append('<a href="#" onclick="loadSurveyList(1);return false;">' + '<img src="' + FIRST_IMG_URL + '" border="0"/></a>&#160;');
			} else {
				$pg.append('<img src="' + FIRST_IMG_URL + '" border="0" class="disabled"/></a>&#160;');
			}
			
			// '이전 10페이지' 버튼
			if (startPage > 1) {
			    $pg.append('<a href="#" onclick="loadSurveyList(' + (startPage - 1) + ');return false;">' + '<img src="' + PREV_IMG_URL + '" border="0"/></a>&#160;');
			} else {
				$pg.append('<img src="' + PREV_IMG_URL + '" border="0" class="disabled"/></a>&#160;');
			}
			
			// 개별 페이지 번호 링크
			for (var i = startPage; i <= endPage; i++) {
			    if (i === currentPage) {
			        $pg.append('<strong>' + i + '</strong>&#160;'); // 선택된 페이지만 굵게
			    } else {
			        $pg.append(
			          '<a href="#" onclick="loadSurveyList(' + i + ');return false;">' +
			           i +
			          '</a>&#160;'
			        );
			    }
			}
			
			// '다음 10페이지' 버튼
			if (endPage < totalPages) {
			    $pg.append('<a href="#" onclick="loadSurveyList(' + (endPage + 1) + ');return false;">' + '<img src="' + NEXT_IMG_URL + '" border="0"/></a>&#160;');
			} else {
				$pg.append('<img src="' + NEXT_IMG_URL + '" border="0" class="disabled"/></a>&#160;');
			}
			
			// '마지막으로' 버튼
			if (currentPage < totalPages) {
			    $pg.append('<a href="#" onclick="loadSurveyList(' + totalPages + ');return false;">' + '<img src="' + LAST_IMG_URL + '" border="0"/></a>&#160;');
			} else {
				$pg.append('<img src="' + LAST_IMG_URL + '" border="0" class="disabled"/></a>&#160;');
			}
		}
		
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
    <h2>참여 가능한 설문 목록</h2>
    
	<!-- 사용자 로그인 상태 영역 -->
	<div id="userInfo">
		<span id="loginMsg"></span>
		<button type="button" id="btnGoLogin">로그인하러가기</button>
		<button type="button" id="btnLogout">로그아웃</button>
	</div>
	
	<!-- 검색 영역 -->
	<div id="searchArea" style="margin-bottom:1em;">
		<label for="searchType">검색조건:</label>
		<select id="searchType">
			<option value="userName">작성자</option>
			<option value="title">제목</option>
		</select>
		<label for="searchKeyword">검색어:</label>
		<input type="text" id="searchKeyword" />
		<button type="button" id="btnSearch">검색</button>
	</div>
	
	<div id="searchInfo"></div>
	<p>전체: <span class="count-red"></span>건</p>
	
    <table id="surveyListTbl" border="1">
    	<thead>
	        <tr>
	            <th>순번</th>
	            <th>제목</th>
	            <th>개요</th>
	            <th>설문 시작일</th>
	            <th>설문 종료일</th>
	        </tr>
    	</thead>
    	<tbody></tbody>
    </table>
    
    <div id="paginationArea"></div>
    
    <button type="button" id="btnGoSurveyManage">설문 관리 페이지로 이동</button>
    
    <script>
	    $(function(){
	    	loadSurveyList(currentPageIndex);
	    	
			// 검색 영역 초기값 반영
			$('#searchType').val(currentSearchType);
			$('#searchKeyword').val(currentSearchKeyword);
			
			// 검색 버튼
			$('#btnSearch').click(function(){
				currentPageIndex = 1;
				currentSearchType = $('#searchType').val();
				currentSearchKeyword = $('#searchKeyword').val().trim();
				loadSurveyList(1);
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
	        
	        // 관리자면 설문 관리 페이지 이동 버튼 표시
	        if (isAdmin == 'true') {
	        	$('#btnGoSurveyManage').show();
	        } else {
	        	$('#btnGoSurveyManage').hide();
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
	        
	        // 설문 관리 페이지 이동 버튼 핸들러
	        $('#btnGoSurveyManage').click(function() {
	        	if (isAdmin == 'true') {
    			    // 설문 관리 페이지로 이동
					postTo('${surveyManageUrl}', {});
	        	} else {
	        		alert('관리자 권한 없음: 설문 관리 페이지 이동 불가');
	        	}

			})
	        
	    });
    </script>
</body>
</html>
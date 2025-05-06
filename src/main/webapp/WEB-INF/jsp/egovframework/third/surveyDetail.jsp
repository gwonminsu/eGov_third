<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>설문 참여(상세)</title>
	<link rel="stylesheet" href="<c:url value='/css/surveyDetail.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- API URL -->
	<c:url value="/api/survey/detail.do" var="detailApi"/>
	<c:url value="/api/survey/questions.do" var="questionsApi"/>
	<c:url value="/api/survey/qimage.do" var="qimageApi"/>
	
	<!-- 목록 페이지 URL -->
	<c:url value="/surveyList.do" var="listUrl"/>
	<!-- 참여 페이지 URL (설문 참여 폼) -->
	<c:url value="/surveyParticipate.do" var="participateUrl"/>
	
	<script>
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

	<h2>설문 참여(상세)</h2>
	
	<!-- 설문 메타 정보가 들어갈 영역 -->
	<table class="survey-info">
		<tr><th>제목</th><td id="svTitle"></td></tr>
		<tr><th>개요</th><td id="svDesc"></td></tr>
		<tr>
			<th>설문 기간</th>
			<td><span id="svStart"></span> ~ <span id="svEnd"></span></td>
		</tr>
	</table>
	
	<!-- 질문 리스트 렌더링 영역 -->
	<div id="questionList"></div>
	
	<div class="btn-area">
		<button type="button" id="btnList">목록</button>
		<button type="button" id="btnGo">설문 참여</button>
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
					var $qList = $('#questionList').empty();
					list.forEach(function(q,i) {
						var requiredMark;
						if(q.isRequired) {
							requiredMark = '<span id="required-mark">＊</span>';
						} else {
							requiredMark = '';
						}
						var $textSpan = $('<span>').addClass('q-text').text(q.content);
						$textSpan.append(requiredMark); // 질문 내용 옆에 필수 마크 추가
					    var $block = $('<div>').addClass('question-block');
					    var $hdr = $('<div>').addClass('question-header').append($('<span>').addClass('q-index').text('Q'+(i+1)), $textSpan);
					    $block.append($hdr);
					
					    var $inp = $('<div>').addClass('q-input');
					    switch(q.type) {
							case 'short':
								$inp.append($('<input>').attr({type:'text', disabled:true}));
								break;
							case 'long':
								$inp.append($('<textarea>').attr({rows:4, disabled:true}));
								break;
							case 'radio':
								q.qitemList.forEach(function(opt){
									$inp.append($('<label>').append($('<input>').attr({type:'radio', disabled:true, name:'r'+i}), ' '+opt+' '));
								});
								break;
							case 'dropdown':
								var $sel = $('<select>').attr('disabled',true).append($('<option>').text('선택'));
								q.qitemList.forEach(function(opt){
									$sel.append($('<option>').text(opt));
								});
								$inp.append($sel);
								break;
							case 'check':
								q.qitemList.forEach(function(opt){
									$inp.append($('<label>').append($('<input>').attr({type:'checkbox', disabled:true}),' '+opt+' '));
								});
								break;
							case 'image':
								var $img = $('<img>').addClass('q-image');
								$inp.append($img);
								$.ajax({
									url: '${qimageApi}',
									type: 'POST',
									contentType: 'application/json',
									data: JSON.stringify({ questionIdx: q.idx }),
									success: function(imgVo) {
										if (imgVo && imgVo.fileUuid) {
											$img.attr('src', '/uploads/' + imgVo.fileUuid + imgVo.ext);
										}
									},
									error: function() {
										alert('질문 이미지를 불러올 수 없습니다');
									}
								});
								break;
							default:
								$inp.append($('<input>').attr({type:'text', disabled:true}));
					    }
					    $block.append($inp);
					    $qList.append($block);
					});
				},
				error: function() {
					alert('질문 목록을 불러올 수 없습니다');
				}
			});

			// 목록 버튼
			$('#btnList').click(function() {
				postTo('${listUrl}', { searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
			});
			// 설문 참여 버튼
			$('#btnGo').click(function() {
				postTo('${participateUrl}', { idx: idx, searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
			});
		});
	</script>
	
</body>
</html>
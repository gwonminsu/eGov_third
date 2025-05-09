<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>설문 참여</title>
	<link rel="stylesheet" href="<c:url value='/css/surveyParticipate.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- API URL -->
	<c:url value="/api/survey/detail.do" var="detailApi"/>
	<c:url value="/api/survey/questions.do" var="questionsApi"/>
	<c:url value="/api/survey/qimage.do" var="qimageApi"/>
	<c:url value="/api/answer/submit.do" var="submitApi"/>
	
	<!-- 설문 상세 페이지 URL -->
	<c:url value="/surveyDetail.do" var="detailUrl"/>
	<!-- 참여 페이지 URL (설문 참여 폼) -->
	<c:url value="/surveyParticipate.do" var="participateUrl"/>
	
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

	<h2 id="participateTitle">설문 참여</h2>
	
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
	
	<!-- 질문 & 응답 입력 영역 -->
	<div id="questionList"></div>
	
	<div class="btn-area">
		<button type="button" id="btnPrev">이전</button>
		<button type="button" id="btnDone">설문 답변 제출</button>
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

			// 질문 목록 조회 + 응답 입력 요소 렌더링
			$.ajax({
				url: '${questionsApi}',
				type: 'POST',
				contentType: 'application/json',
				data: JSON.stringify({ surveyIdx: idx }),
				success: function(list) {
					var $qList = $('#questionList').empty();
					list.forEach(function(q, i) {
						var requiredMark;
						if(q.isRequired) {
							requiredMark = '<span id="required-mark">＊</span>';
						} else {
							requiredMark = '';
						}
						var $textSpan = $('<span>').addClass('q-text').text(q.content);
						$textSpan.append(requiredMark); // 질문 내용 옆에 필수 마크 추가
					    var $block = $('<div>').addClass('question-block').attr('data-q-idx', q.idx).attr('data-q-type', q.type);
					    var $hdr = $('<div>').addClass('question-header')
					    						.append($('<span>').addClass('q-index').text('Q'+(i+1)), $textSpan);
					    $block.append($hdr);
					
					    var $content = $('<div>').addClass('q-content');
					    
					    var $img = $('<img>').addClass('q-image');
					    $content.append($img);
						$.ajax({
							url: '${qimageApi}',
							type: 'POST',
							contentType: 'application/json',
							data: JSON.stringify({ questionIdx: q.idx }),
							success: function(imgVo) {
								if (imgVo && imgVo.fileUuid) {
									$img.attr('src', '/uploads/' + imgVo.fileUuid + imgVo.ext);
								} else {
									$content.find($img).remove();
								}
							},
							error: function() {
								alert('질문 이미지를 불러올 수 없습니다: ' + i);
							}
						});
					    
					    switch(q.type) {
							case 'short':
								$content.append($('<input>').attr({type:'text', name:'ans_' + q.idx, maxlength: '25'}));
								break;
							case 'long':
								$content.append($('<textarea>').attr({rows:4, name:'ans_' + q.idx}));
								break;
							case 'radio':
								q.qitemList.forEach(function(opt){
									console.log(JSON.stringify(opt));
									$content.append($('<label>').append($('<input>').attr({type: 'radio', name:'ans_' + q.idx, value: opt.idx}), ' '+opt.content+' '));
								});
								break;
							case 'dropdown':
								var $sel = $('<select>').attr({name:'ans_' + q.idx}).append($('<option>').text('선택'));
								q.qitemList.forEach(function(opt){
									$sel.append($('<option>').attr('value', opt.idx).text(opt.content));
								});
								$content.append($sel);
								break;
							case 'check':
								q.qitemList.forEach(function(opt){
									$content.append($('<label>').append($('<input>').attr({type:'checkbox', name:'ans_' + q.idx, value: opt.idx}),' '+opt.content+' '));
								});
								break;
							default:
								$content.append($('<input>').attr({type:'text'}));
					    }
					    $block.append($content);
					    $qList.append($block);
					});
				},
				error: function() {
					alert('질문 목록을 불러올 수 없습니다');
				}
			});

			// 목록 버튼
			$('#btnPrev').click(function() {
				postTo('${detailUrl}', { idx: idx, searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
			});
			// 설문 답변 제출 버튼
			$('#btnDone').click(function() {
				  var payload = {
					  surveyResponse: {
						  surveyIdx: idx,
						  userIdx: sessionUserIdx
					  },
					  answerList: []
				  };
			    
			    $('#questionList .question-block').each(function() {
			        var $b = $(this);
			        var qIdx = $b.data('q-idx');
			        var type = $b.data('q-type');
			        
			        if (type === 'check') {
			        	$b.find('input:checkbox:checked').each(function() {
			        		// 체크된 항목 정보들 배열에 추가
			        		payload.answerList.push({ questionIdx: qIdx, qitemIdx: $(this).val(), content: null })
			        	});
			        } else if (type === 'radio') {
			        	var sel = $b.find('input:radio:checked').val();
			        	// 체크된 항목 정보 배열에 추가
			        	if (sel !== undefined) { // 체크된거 없으면
			        		payload.answerList.push({ questionIdx: qIdx, qitemIdx: sel, content: null });
			        	}
			        } else if (type === 'dropdown') {
			        	var sel = $b.find('select').val();
			        	if (sel && sel !== '선택') { // '선택'이 아니고 빈 문자열도 아닐 때만
			        		payload.answerList.push({ questionIdx: qIdx, qitemIdx: sel, content: null });
			        	}
			        } else if (type === 'short') {
			        	var txt = $b.find('input[name="ans_' + qIdx + '"]').val();
			        	if (txt) {
			        		payload.answerList.push({ questionIdx: qIdx, qitemIdx: null, content: txt });
			        	}
			        } else if (type === 'long') {
			        	var txt = $b.find('textarea[name="ans_' + qIdx + '"]').val();
			        	if (txt) {
			        		payload.answerList.push({ questionIdx: qIdx, qitemIdx: null, content: txt });
			        	}
			        }
			    });
			
	        	console.log("현재 배열 상태: " + JSON.stringify(payload));
	        	
	        	$.ajax({
	        		url: '${submitApi}',
	        		type: 'POST',
	        		contentType:'application/json',
	                data: JSON.stringify(payload),
	                success: function(){
	                    alert('제출 완료');
	                    postTo('${detailUrl}', { idx: idx, searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
	                },
	                error: function(){
	                    alert('제출 실패');
	                }
	        	});
			});
		});
	</script>
	
</body>
</html>
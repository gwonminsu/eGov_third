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
	<c:url value="/api/answer/stats.do" var="statsApi"/>
	<c:url value="/api/survey/qimage.do" var="qimageApi"/>
	
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
			postTo('${surveyManageUrl}', { searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
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
					var $container = $('#questionStatsInfo').empty();
					list.forEach(function(q, i) {
						var typeLabels = { short: '단답형', long: '장문형', radio: '라디오', dropdown:'드롭다운', check: '체크박스' };
						var $requiredMark;
						if(q.isRequired) {
							$requiredMark = '<span id="required-mark">＊</span>';
						} else {
							$requiredMark = '';
						}
						// 질문 블록
						var $block = $('<div>')
										.addClass('question-block')
										.attr('data-q-idx', q.idx)
										.attr('data-q-type', q.type);
						
						// 헤더
						var $hdr = $('<div>').addClass('question-header').append(
								$('<span>').addClass('q-index').text('Q' + (i+1) + '.'),
								$('<span>').addClass('q-type').text('[' + typeLabels[q.type] + '] ')
									.append($('<span>').addClass('q-text').text(q.content))
									.append($requiredMark)
							);
						$block.append($hdr);
						
						// 이미지 렌더링
					    var $img = $('<img>').addClass('q-image');
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
						
						// 콘텐츠(응답 개수 + 세부)
						var $content = $('<div>').addClass('q-content');
						var $respNum = $('<div>').addClass('response-count').text('응답 0개');
						$content.append($img).append($respNum);
						$block.append($content);
						$container.append($block);
						
						// 통계 데이터 조회(답변 목록)
						$.ajax({
							url: '${statsApi}',
                            type: 'POST',
                            contentType: 'application/json',
                            data: JSON.stringify({ questionIdx: q.idx }),
                            success: function(ansList) {
                            	console.log(JSON.stringify(ansList));
                            	var users = {}; // 대답 사용자 수 체크용
                            	ansList.forEach(a => { users[a.userIdx] = true; }); // userIdx를 key로 객체에 저장(중복 제거 효과 있음)
                            	var respCount = Object.keys(users).length; // 배열로 변환해서 길이 체크
                            	$content.find('.response-count').text('응답 ' + respCount + '개');
                            	
                            	if(q.type === 'short' || q.type === 'long') {
                            		// 주관식 타입일 경우 모든 답변 나열
                            		var contentCounts = {}; // 내용 중복 개수 카운트
                            		ansList.forEach(a => {
                                        var txt = (a.content||'').trim();
                                        if (txt) contentCounts[txt] = (contentCounts[txt]||0) + 1;
                                    });
                            		var $list = $('<div>').addClass('answer-list');
                            		Object.keys(contentCounts).forEach(function(txt) {
                            			var cnt = contentCounts[txt];
                                        var $item = $('<div>').addClass('answer-item')
                                        						.append($('<span>').addClass('count-circle').text(cnt))
                                        						.append($('<span>').text(txt));
                                        $list.append($item);
                            		});
                            		$content.append($list);
                            	} else {
                            		// 객관식 타입일 경우 각 옵션별 응답자 수
                            		var counts = {};
                            		ansList.forEach(a => { // 각 옵션 id에 응답자id 배열 저장
                            			counts[a.qitemIdx] = counts[a.qitemIdx] || {};
                            			counts[a.qitemIdx][a.userIdx] = true;
                            		})
                                    q.qitemList.forEach(opt => {
                                        var num = 0;
                                        if (counts[opt.idx]) {
                                            num = Object.keys(counts[opt.idx]).length; // 옵션 id에 해당하는 사용자 수 계산
                                        }
                                        $content.append($('<div>').addClass('option-stats').text(opt.content + ' : ' + num + '명'));
                                        
                                        console.log('옵션 내용: ' + opt.content + ', 응답자 수: ' + num + '명');
                                    });
                            	}
                            },
                            error: function() {
                            	$content.append($('<div>').addClass('error').text('통계를 불러올 수 없습니다'));
                            }
						});
						
/* 						var $canvas  = $('<canvas>').attr('id', 'chart-' + q.idx);
						$content.append($canvas); */
					});
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
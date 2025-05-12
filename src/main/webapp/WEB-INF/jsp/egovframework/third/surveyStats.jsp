<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>설문 통계</title>
	<link rel="stylesheet" href="<c:url value='/css/surveyStats.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	<script src="<c:url value='/js/chart.umd.js'/>"></script>
	<script src="<c:url value='/js/chartjs-plugin-datalabels.js'/>"></script>
	
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
		
		// datalabels 플러그인 등록
		Chart.register(ChartDataLabels);
		var chartInstances = {}; // 차트 인스턴스 저장용 객체
	
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
                            		var counts = {}; // 문항에 대한 응답자 수를 구하기 위한 객체
                            		var labels = []; // 문항 content 배열
                            		var respData = []; // 문항에 대한 응답자 수 배열
                            		ansList.forEach(a => { // 각 옵션 id에 응답자id 배열 저장
                            			counts[a.qitemIdx] = counts[a.qitemIdx] || {};
                            			counts[a.qitemIdx][a.userIdx] = true;
                            		})
                                    q.qitemList.forEach(opt => {
                                    	labels.push(opt.content);
                                        var num = 0;
                                        if (counts[opt.idx]) {
                                            num = Object.keys(counts[opt.idx]).length; // 옵션 id에 해당하는 사용자 수 계산
                                        }
                                        respData.push(num);
                                        // $content.append($('<div>').addClass('option-stats').text(opt.content + ' : ' + num + '명'));
                                    });
                            		console.log('라벨: ' + JSON.stringify(labels));
                            		console.log('데이터: ' + JSON.stringify(respData));
                            		
									var $tab = $(`
										<div class="tab">
											<ul class="tabnav">
												<li><a href="#pie-\${q.idx}">파이차트</a></li>
												<li><a href="#bar-\${q.idx}">막대차트</a></li>
											</ul>
											<div class="tabcontent">
												<div id="pie-\${q.idx}">
													<canvas id="chart-pie-\${q.idx}"></canvas>
												</div>
												<div id="bar-\${q.idx}">
													<canvas id="chart-bar-\${q.idx}"></canvas>
												</div>
											</div>
										</div>
									`);
                            		$content.append($tab);
                            		
                            		// 기본 탭 숨김/첫 탭 활성화
                            		$tab.find('.tabcontent > div').hide();
                            		$tab.find('.tabnav a').filter(':eq(0)').addClass('active');
                            		$tab.find('#pie-' + q.idx).show();

                            		// 탭 클릭 바인딩
                            		$tab.find('.tabnav a').click(function(){
										var $thisTab = $(this).closest('.tab');
										$thisTab.find('.tabcontent > div').hide().filter(this.hash).fadeIn();
										$thisTab.find('.tabnav a').removeClass('active');
										$(this).addClass('active');
										
										// 클릭된 차트 리셋, 업데이트
									    var chartKey = this.hash.substring(1);
									    var chart = chartInstances[chartKey];
									    if (chart) {
								        	chart.reset(); // 차트를 초기 상태로 되돌림
									        chart.update(); // 다시 애니메이션 실행
									    }
										
										return false;
                            		});
                            		
                            		// 파이 차트 그리기
                            		var pieCtx = $('#chart-pie-' + q.idx).get(0).getContext('2d');
                            		var pieChart = new Chart(pieCtx, {
                                        type: 'pie',
                                        data: {
                                            labels: labels,
                                            datasets: [{
                                                data: respData,
                                                backgroundColor: [
                                                    '#FF6633','#FFB399','#FF33FF','#FFFF99','#00B3E6',
                                                    '#E6B333','#3366E6','#999966','#99FF99','#B34D4D',
                                                    '#80B300','#809900','#E6B3B3','#6680B3','#66991A',
                                                    '#FF99E6','#CCFF1A','#FF1A66','#E6331A','#33FFCC'
                                                ]
                                            }]
                                        },
                                        options: {
                                            responsive: true,
                                            maintainAspectRatio: false,
                                            plugins: {
                                            	legend: {
                                            		display: true,
                                            		position: 'right',
                                            		align: 'center',
                                            		labels: { boxWidth: 12, padding: 8 }
                                            	},
												datalabels: {
													display: ctx => ctx.dataset.data[ctx.dataIndex] > 0, // 0인 값은 라벨 나오지 않게
													color: '#fff',
													formatter: (value, ctx) => {
														var label = ctx.chart.data.labels[ctx.dataIndex];
														var data = ctx.chart.data.datasets[0].data;
														var sum = data.reduce((a, b) => a + b, 0);
														var percent = ((value / sum) * 100).toFixed(1) + '%';
														return label + '\n' + percent + '\n(' + value + '명)';
													},
													font: {
														weight: 'bold',
														size: 12
													},
													textAlign: 'center',
													anchor: 'center',
													align: 'center'
												}
                                            }
                                        }
                            		});
                            		chartInstances['pie-' + q.idx] = pieChart;
                            		
                            		// 막대차트 그리기
                            		var barCtx = document.getElementById('chart-bar-' + q.idx).getContext('2d');
                            		var barChart = new Chart(barCtx, {
									type: 'bar',
									data: {
										labels: labels,
										datasets: [{ label:'응답 수', data: respData }]
									},
									options: {
										responsive:true, maintainAspectRatio:false,
										scales:{ y:{ beginAtZero:true } }
									}
                            		});
                            		chartInstances['bar-' + q.idx] = barChart;
                            		
                            	}
                            },
                            error: function() {
                            	$content.append($('<div>').addClass('error').text('통계를 불러올 수 없습니다'));
                            }
						});
						
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
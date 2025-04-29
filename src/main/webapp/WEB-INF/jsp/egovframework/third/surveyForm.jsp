<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>설문 작성</title>
	
	<link rel="stylesheet" href="<c:url value='/css/surveyForm.css'/>" />
	<link rel="stylesheet" href="<c:url value='/css/jquery-ui.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	<script src="<c:url value='/js/jquery-ui.min.js'/>"></script>
	
	<!-- 목록 페이지 URL -->
	<c:url value="/surveyList.do" var="listUrl"/>
	<!-- API URL -->
    <c:url value="/api/survey/create.do" var="createApi"/>
    <c:url value="/api/survey/edit.do"   var="editApi"/>
    <c:url value="/api/survey/detail.do" var="detailApi"/>
    <!-- 데이트피커 이미지 url -->
    <c:url value="/images/datepicker.png" var="datepickerImgUrl"/>
	
	<script>
		var sessionUserIdx  = '<c:out value="${sessionScope.loginUser.idx}" default="" />';
		var sessionUserName = '<c:out value="${sessionScope.loginUser.userName}" default="" />';
		
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
	<h2 id="formTitle">📋설문지 관리(작성)</h2>
	<h3 id="surveyFormGuide">현재 수정중인 설문 idx: <span id="idxShow"></span></h3>
	
	<table class="form-table">
		<tr>
			<th>제목</th>
			<td colspan="3">
				<input type="text" id="title" required maxlength="100"/>
			</td>
		</tr>
		<tr>
			<th>개요</th>
			<td colspan="3">
				<textarea id="description" rows="1" required oninput="this.style.height='auto'; this.style.height=this.scrollHeight+'px';"></textarea>
			</td>
		</tr>
		<tr>
			<th>설문 시작일</th>
			<td>
				<div class="date-container">
					<input type="text" id="datepickerStart" readonly />
				</div>
			</td>
			<th>설문 종료일</th>
			<td>
				<div class="date-container">
					<input type="text" id="datepickerEnd" readonly />
				</div>
			</td>
		</tr>
		<tr>
			<th>사용 여부</th>
			<td colspan="3">
				<label>
					<input type="radio" name="isUse" value="true" checked /> 사용
				</label>
				<label style="margin-left:16px;">
					<input type="radio" name="isUse" value="false" /> 미사용
				</label>
			</td>
		</tr>
		<tr>
			<th>질문 내용</th>
			<td colspan="3">
				<!-- 질문 아이템들이 쌓일 컨테이너 -->
				<div id="questionList"></div>
				<!-- 여기는 질문 추가 영역 -->
				<table id="addQuestionTable">
					<tr>
						<th colspan="2" id="qAddHeader">
							<div id="qHint">설문지 질문 추가</div>
							<button type="button" id="addBtn">추가</button>
						</th>
					</tr>
					<tr>
						<th>질문 타입</th>
						<td>
							<select id="qTypeSelect">
								<option value="short">단답형</option>
								<option value="long">장문형</option>
								<option value="radio">객관식(라디오)</option>
								<option value="dropdown">객관식(드롭다운)</option>
								<option value="check">다중 객관식(체크박스)</option>
								<option value="image">이미지</option>
							</select>
						</td>
					</tr>
					<tr id="qInputRow">
						<th>질문</th>
						<td>
							<input type="text" id="qContent" /> <!-- 기본으로 단답형 -->
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>

	<div class="btn-area">
		<button id="btnSubmit">저장</button>
		<button id="btnCancel">취소</button>
	</div>
	<button id="checkArray" >현재 배열 확인하기</button>

	<script>
		// JSP EL로 POST 폼 파라미터 idx 바로 읽기
		var idx = '${param.idx}';  
		var mode   = idx ? 'edit' : 'create';
		// 모드에 따라 apiUrl 주소 변경
		var apiUrl = mode === 'edit' ? '${editApi}' : '${createApi}';	
	
	    $(function(){
 	    	if (mode === 'edit') {
	    		$('#formTitle').text('설문지 관리(수정)');
	    		$('#surveyFormGuide').show();
	    		$('#idxShow').text(idx);
	    		// 게시글 상세 정보 가져와서 input에 채워넣기
	    		$.getJSON('${detailApi}', { idx: idx }, function(item) {
		   	        $('#title').val(item.title);
		   	        $('#description').html(item.description);
	    		});
	    	} else {
	    		$('#surveyFormGuide').hide();
	    	}
 	    	
	    	// 작성자 input에 세션의 사용자 이름 넣기
	    	// $('#userName').val(sessionUserName);
	    	
	    	// 데이트피커 기본옵션 정의
	    	var datepickerOptions = {
				dateFormat: 'yy-mm-dd', // 달력 날짜 형태
				showOtherMonths: true, // 빈 공간에 현재월의 앞뒤월의 날짜를 표시
				showMonthAfterYear: true, // 월- 년 순서가아닌 년도 - 월 순서
				changeYear: true, // option값 년 선택 가능
				changeMonth: true, // //option값  월 선택 가능 
				showOn: "both", // input이나 버튼을 눌러야만 달력 표시
				buttonImage: '${datepickerImgUrl}',
				buttonImageOnly: true, // 버튼 이미지만 깔끔하게 표시
				buttonText: "선택", // 버튼 호버 텍스트
				yearSuffix: "년", // 달력의 년도 부분 뒤 텍스트
				monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
				monthNames: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'], // 툴팁
				dayNamesMin: ['일','월','화','수','목','금','토'],
				dayNames: ['일요일','월요일','화요일','수요일','목요일','금요일','토요일'],
				minDate: "-5Y", //최소 선택일자
				maxDate: "+5y" //최대 선택일자
	    	}
			
			// 데이트피커 옵션적용과 오늘 날짜로 초기값 세팅
			$("#datepickerStart").datepicker(datepickerOptions).datepicker('setDate', 'today');
			$("#datepickerEnd").datepicker(datepickerOptions).datepicker('setDate', 'today');
			
			
	    	/* --------------------------- 질문 리스트 관련 스크립트 시작 ------------------------------- */
	    	
			// 질문 객체 리스트
			var questions = [];
	    	// 객관식 옵션 객체 리스트
	    	var currentOptions = [];
	    	
	    	// 타입-라벨 매핑 객체
	    	var typeLabels = {
				short: '단답형',
				long:  '장문형',
				radio: '라디오',
				dropdown:'드롭다운',
				check: '체크박스',
				image: '이미지'
			};
	    	
			// 질문 입력 폼 초기화
			function resetForm(){
				$('#qTypeSelect').val('short');
				renderTypeForm('short');
				$('#qContent').val('');
				$('#addBtn').show();
				$('#saveBtn')?.remove();
				currentOptions = []; // 현재 옵션 리셋
				$('#optionInputRow, #optionListRow').remove();
			}
			
			// 타입 드롭다운 변경 시
			$('#qTypeSelect').on('change', function(){
				currentOptions = [];
				var type = $(this).val();
				renderTypeForm(type);
			});
			
			// 질문 추가 테이블 폼 변경
			function renderTypeForm(type){
				var $table = $('#addQuestionTable');
				if(type === 'long') {
					$('#qInputRow td').html('<textarea id="qContent" rows="4" style="width:100%"></textarea>');
				} else {
					$('#qInputRow td').html('<input type="text" id="qContent" style="width:100%"/>');
				}
			    // 이미 찍혀있던 옵션 영역 제거
			    $table.find('#optionInputRow, #optionListRow').remove();
			    // 객관식 타입이면 옵션 입력/목록 로우 추가
			    if(type==='radio' || type==='dropdown' || type==='check') {
					$(`<tr id="optionInputRow">
					        <th>응답 옵션</th>
					        <td>
					          <input type="text" id="optionContent" style="width:70%"/>
					          <button type="button" id="addOptionBtn">추가</button>
					        </td>
					      </tr>`).insertAfter('#qInputRow'); // qInputRow 다음에 추가
					$(`<tr id="optionListRow">
					        <th>옵션 리스트</th>
					        <td><ul id="optionList" style="list-style:none;padding:0;margin:0"></ul></td>
					      </tr>`).insertAfter('#optionInputRow'); // optionInputRow 다음에 추가
			    }
			}
			
			// 옵션 리스트 렌더링
			function renderOptionList(){
				var $ul = $('#optionList').empty();
				currentOptions.forEach((opt, i) => {
					var $li = $(`<li data-idx="\${i}" style="margin-bottom:4px">
					                 \${opt}
					                 <button class="optUpBtn">▲</button>
					                 <button class="optDownBtn">▼</button>
					                 <button class="optDelBtn">X</button>
					               </li>`);
					$ul.append($li);
				});
			}
			
			// 질문 아이템 렌더링 함수
			function renderQuestionList(){
				var $list = $('#questionList').empty();
				questions.forEach((q, idx) => {
					var label = typeLabels[q.type] || typeLabels.short;
					var $tbl = $(`
						<table class="question-item" data-index="\${idx}" >
							<tr>
								<th colspan="2">
									<div class="th-content">
										<span class="label-text">\${label} 질문 [idx: \${idx}]</span>
										<span class="btn-group">
											<button class="modifyBtn">수정</button>
											<button class="deleteBtn">삭제</button>
											<button class="upBtn">▲</button>
											<button class="downBtn">▼</button>
										</span>
									</div>
								</th>
							</tr>
							<tr>
								<th>질문</th>
								<td>\${q.content}</td>
							</tr>
						</table>`);
					// 옵션리스트가 있으면 아래에 로우 추가
					if(q.qitemList){
					  var optsHtml = q.qitemList.map(o=>`<div>▪ \${o}</div>`).join('');
					  $tbl.append(`<tr><th>응답 옵션</th><td>\${optsHtml}</td></tr>`);
					}
					$list.append($tbl);
				});
			}
			
			// 질문 추가 버튼
			$('#addBtn').on('click', function(){
				var type = $('#qTypeSelect').val();
				var content = $('#qContent').val()?.trim();
				if(!content) {
					alert('질문을 입력해주세요');
					return;
				}
				var qObj = { type, content };
				// 타입이 객관식이면 옵션 필수 체크
			    if(type==='radio'||type==='dropdown'||type==='check'){
					if(currentOptions.length<1) return alert('옵션을 하나 이상 추가해주세요');
					qObj.qitemList = [...currentOptions];
				}
				// 새 질문 객체 push
				questions.push(qObj);
				renderQuestionList();
				resetForm();
			});
			
			// 수정 모드로 진입
			$('#questionList').on('click', '.modifyBtn', function(){
				var idx = +$(this).closest('table').data('index');
				var q = questions[idx];

				$('#qHint').text('설문지 질문 수정');
				
				// 폼에 값 채워주기
				$('#qTypeSelect').val(q.type);
				renderTypeForm(q.type);
				$('#qContent').val(q.content);
				// 객관식이면 기존 옵션들 세팅
				if (q.qitemList) {
					currentOptions = [...q.qitemList];
					renderOptionList();
				}
				
				// 추가 버튼 숨기고 수정완료 버튼 추가
				$('#addBtn').hide();
				if(!$('#saveBtn').length){
					$('#addQuestionTable tr:first th')
					  .append(' <button type="button" id="saveBtn">수정완료</button>');
				}
				
				// 수정완료 클릭 핸들러
				$('#saveBtn').off('click').on('click', function(){
					$('#qHint').text('설문지 질문 추가');
					var newType = $('#qTypeSelect').val();
					var newContent = $('#qContent').val()?.trim();
					if(!newContent){
						alert('질문을 입력해주세요');
						return;
					}
					// 배열 업데이트(객관식일경우 옵션리스트 객체를 배열에 추가)
					var updated = { type: newType, content: newContent };
					if(newType==='radio' || newType==='dropdown' || newType==='check'){
						updated.qitemList = [...currentOptions];
					}
					questions[idx] = updated;
					renderQuestionList();
					resetForm();
				});
			});
			
			// 질문 삭제
			$('#questionList').on('click', '.deleteBtn', function(){
				var idx = +$(this).closest('table').data('index');
				questions.splice(idx, 1);
				renderQuestionList();
			});
			
			// 질문 순서 올리기
			$('#questionList').on('click', '.upBtn', function(){
				var idx = +$(this).closest('table').data('index');
				if(idx > 0){
					[questions[idx-1], questions[idx]] = [questions[idx], questions[idx-1]];
					renderQuestionList();
				}
			});
			
			// 질문 순서 내리기
			$('#questionList').on('click', '.downBtn', function(){
				var idx = +$(this).closest('table').data('index');
				if(idx < questions.length - 1){
					[questions[idx], questions[idx+1]] = [questions[idx+1], questions[idx]];
					renderQuestionList();
				}
			});
			
			// 옵션 추가
			$('#addQuestionTable').on('click', '#addOptionBtn', function(){
				var opt = $('#optionContent').val()?.trim();
				if(!opt) return alert('옵션을 입력해주세요');
				currentOptions.push(opt);
				renderOptionList();
				$('#optionContent').val('').focus();
			});
			
			// 옵션 삭제
			$('#addQuestionTable').on('click','.optDelBtn', function(){
				var i = +$(this).parent().data('idx');
				currentOptions.splice(i,1);
				renderOptionList();
			});
			
			// 옵션 순서 올리기
			$('#addQuestionTable').on('click','.optUpBtn', function(){
				var i = +$(this).parent().data('idx');
				if(i>0){ [currentOptions[i-1],currentOptions[i]]=[currentOptions[i],currentOptions[i-1]]; renderOptionList(); }
			});
			
			// 옵션 순서 내리기
			$('#addQuestionTable').on('click','.optDownBtn', function(){
				var i = +$(this).parent().data('idx');
				if(i<currentOptions.length-1){ [currentOptions[i],currentOptions[i+1]]=[currentOptions[i+1],currentOptions[i]]; renderOptionList(); }
			});
			
			$('#checkArray').on('click', function() {
				console.table(questions);
				console.log(JSON.stringify(questions));
			});
	    	
	    	/* --------------------------- 질문 리스트 관련 스크립트 끝 --------------------------------- */
			
	    	
	        $('#btnSubmit').click(function(){
	        	// 폼 검증(하나라도 인풋이 비어있으면 알림)
	    		if (!$('#title')[0].reportValidity()) return;
	    		if (!$('#description')[0].reportValidity()) return;
	    		
				// Date 객체로 가져오기
				var startObj = $("#datepickerStart").datepicker("getDate");
				var endObj   = $("#datepickerEnd").datepicker("getDate");
				// 종료 날짜가 시작날짜보다 빠른지 체크
				if (endObj < startObj) {
					alert("종료일이 시작일보다 빠릅니다! 날짜를 다시 확인해주세요");
					return;
				}
				// 문자열 포맷 변환 (yyyy-MM-dd)
				var startStr = $.datepicker.formatDate("yy-mm-dd", startObj);
				var endStr   = $.datepicker.formatDate("yy-mm-dd", endObj);
				
				// 사용 여부 값 가져오기
				var isUseVal = $('input[name="isUse"]:checked').val() === 'true';
	        	
	    		// 검증 통과 시 게시글 등록 api 실행
	    		var data = {
	    				authorIdx: sessionUserIdx,
	    				title: $('#title').val(),
	    				description: $('#description').val(),
	    				startDate: startStr,
	    				endDate: endStr,
	    				isUse: isUseVal
	    				}; // 보낼 데이터
	    		if (mode==='edit') data.idx = idx; // 수정 모드면 idx 추가
	    		
	    		console.log("data: " + JSON.stringify(data));
	    		
	    		// 설문지 등록 요청
	    		$.ajax({
	    			url: apiUrl + (mode==='edit' ? '?idx='+encodeURIComponent(idx) : ''),
	    			type:'POST',
	    			contentType:'application/json',
	    			data: JSON.stringify(data),
	    			success: function(res){
						if (res.error) {
							alert(res.error);
						} else {
							alert(mode==='edit'?'글 수정 완료':'글 등록 완료');
							postTo('${listUrl}', {});
			            }
	    			},
					error: function(xhr){
						var errMsg = xhr.responseJSON && xhr.responseJSON.error; // 인터셉터에서 에러메시지 받아옴
						if (!errMsg) {
							try {
								errMsg = JSON.parse(xhr.responseText).error;
							} catch (e) {
								errMsg = '게시글 ' + (mode==='edit'?'수정':'등록') + ' 중 에러 발생'
							}
						}
						alert(errMsg);
					}
	    		});
	    		
	    		// 질문 등록/옵션 등록 요청 예정
	        });
	    	
	    	$('#btnCancel').click(function() {
	    		// 게시글 목록 페이지 이동
	    		postTo('${listUrl}', {});
	    	});
	    	
	    });
	</script>
</body>
</html>
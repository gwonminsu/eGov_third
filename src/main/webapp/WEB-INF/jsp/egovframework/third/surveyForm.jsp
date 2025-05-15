<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
	<c:url value="/surveyManage.do" var="surveyManageUrl"/>
	<!-- API URL -->
    <c:url value="/api/survey/create.do" var="createApi"/>
    <c:url value="/api/survey/edit.do" var="editApi"/>
    <c:url value="/api/survey/delete.do" var="deleteApi"/>
    <c:url value="/api/survey/detail.do" var="detailApi"/>
    <c:url value="/api/survey/questions.do" var="questionsApi"/>
    <c:url value="/api/survey/qimage.do" var="qimageApi"/>
    <c:url value="/api/answer/check.do" var="checkResponseApi"/>
    <c:url value="/api/answer/resList.do" var="resListApi"/>
    <!-- 데이트피커 이미지 url -->
    <c:url value="/images/datepicker.png" var="datepickerImgUrl"/>
	
	<script>
		var sessionUserIdx = '<c:out value="${sessionScope.loginUser.idx}" default="" />';
		var isAdmin = '<c:out value="${sessionScope.loginUser.role}" default="" />';
		
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
	<h2 id="formTitle">📋설문지 관리(작성)</h2>
	<div id="surveyFormGuide"><h3>현재 수정중인 설문 idx: <span id="idxShow"></span></h3></div>
	
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
						<th colspan="2">
							<div id="qAddHeader">
								<div style="display:flex;">
									<span id="switch-text">필수 여부</span>
									<div class="switch-container">
										<input type="checkbox" id="isRequiredSwitch">
										<label for="isRequiredSwitch" class="switch-label">
											<span class="onf-btn"></span>
										</label>
									</div>
								</div>
								<div id="qHint">설문지 질문 추가</div>
								<button type="button" id="addBtn">추가</button>
							</div>
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
							</select>
						</td>
					</tr>
					<tr id="qInputRow">
						<th>질문</th>
						<td>
							<textarea id="qContent" rows="1" required oninput="this.style.height='auto'; this.style.height=this.scrollHeight+'px';"></textarea>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>

	<div class="btn-area">
		<button id="btnSubmit">저장</button>
		<button id="btnDelete">삭제</button>
		<button id="btnCancel">취소</button>
	</div>
	<button id="checkArray" >현재 배열 확인하기</button>

	<script>
		// JSP EL로 POST 폼 파라미터 idx 바로 읽기
		var idx = '${param.idx}';  
		var mode = idx ? 'edit' : 'create';
		// 모드에 따라 apiUrl 주소 변경
		var apiUrl = mode === 'edit' ? '${editApi}' : '${createApi}';	
		// 설문 응답 여부
		var hasResponded = false;
		var originQuestions = [];
	
	    $(function(){
			// 설문 응답 여부 조회	
			$.ajax({
				url: '${resListApi}',
				type: 'POST',
				contentType: 'application/json',
				data: JSON.stringify({ surveyIdx: idx }),
				success: function(resList) {
					if (resList.length > 0) {
						hasResponded = true;
						if (hasResponded) {
							$('#surveyFormGuide').append($('<div>').addClass('notice-box').text("⚠ 현재 수정하고 있는 설문은 응답 이력이 있으므로 질문 수정이 불가합니다."));
						}
					}
				},
				error: function(){
					console.error('응답 개수 조회 실패');
				}
			});
	    	
 	    	if (mode === 'edit') {
	    		$('#formTitle').text('설문지 관리(수정)');
	    		$('#surveyFormGuide').show();
	    		$('#idxShow').text(idx);
	    		
	    		// 설문 메타 정보 가져와서 input에 채워넣기
	    		$.ajax({
	    			url: '${detailApi}',
	    			type: 'POST',
	    			contentType: 'application/json',
	    			data: JSON.stringify({ idx: idx }),
	    			dataType: 'json'
	    		}).done(function(item) {
		   	        $('#title').val(item.title);
		   	        $('#description').val(item.description);
					$("#datepickerStart").datepicker('setDate', item.startDate);
					$("#datepickerEnd").datepicker('setDate', item.endDate);
					$('input[name="isUse"][value="'+ item.isUse +'"]').prop('checked', true);
				});
	    		
	    		// 질문 목록 가져와서 question 배열에 채워넣기
	    		$.ajax({
	    			url: '${questionsApi}',
	    			type: 'POST',
	    			contentType: 'application/json',
	    			data: JSON.stringify({ surveyIdx: idx }),
	    			dataType: 'json'
	    		}).done(function(qList) {
	    			// qitemList가 vo 객체 배열로 오기 때문에 content 배열로 가공
	    			qList.forEach(question => {
	    				question.qitemList = question.qitemList.map(item => item.content); // qitemList의 내용을 content로 덮어쓰기
	    			});
	    			originQuestions = JSON.stringify(qList);
					questions = qList;
					var calls = questions.map(function(q) {
						return $.ajax({
							url: '${qimageApi}',
				            type: 'POST',
				            contentType: 'application/json',
				            data: JSON.stringify({ questionIdx: q.idx })
						}).done(function(img) {
							if (img && img.fileUuid) {
								q.imageData = '/uploads/' + img.fileUuid + img.ext;
							}
						})
						.fail(function() {
							// 이미지 없으면 넘어가
						});
					});
					// 모든 qimage 호출 끝나면 렌더링
					$.when.apply($, calls).always(function(){
						renderQuestionList();
					});
				});
	    	} else {
	    		$('#surveyFormGuide').hide();
	    	}
	    	
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
	    	
			var questions = []; // 질문 객체 리스트
	    	var currentOptions = []; // 객관식 옵션 객체 리스트
			var currentImage = null; // 이미지 파일 객체
			var currentImageData = null; // DataURL 미리보기
			var editingIndex = null; // 현재 수정 중인 질문 인덱스
			
			resetForm(); // 폼 초기화
	    	
	    	// 타입-라벨 매핑 객체
	    	var typeLabels = {
				short: '단답형',
				long: '장문형',
				radio: '라디오',
				dropdown:'드롭다운',
				check: '체크박스'
			};
	    	
			// 질문 입력 폼 초기화
			function resetForm() {
				$('#qTypeSelect').val('short');
				renderTypeForm('short');
				$('#qContent').val('');
				$('#addBtn').show();
				$('#saveBtn')?.remove();
				$('#isRequiredSwitch').prop('checked', false); // 필수 여부 초기화
				currentOptions = []; // 현재 옵션 초기화
			    // 이미지 초기화
			    currentImage = null;
			    currentImageData = null;
			}
			
			// 타입 드롭다운 변경 시
			$('#qTypeSelect').on('change', function() {
				currentOptions = [];
			    currentImage = null;
			    currentImageData = null;
				var type = $(this).val();
				renderTypeForm(type);
			});
			
			// 질문 추가 테이블 폼 변경
			function renderTypeForm(type) {
				var $table = $('#addQuestionTable');
				$('#qInputRow td').html('<textarea id="qContent" rows="1" required oninput="this.style.height=\'auto\'; this.style.height=this.scrollHeight+\'px\';"></textarea>');

			    // 기존 객관식/이미지 관련 로우 제거
			    $table.find('#optionInputRow, #optionListRow, #imageInputRow, #imagePreviewRow').remove();
			    
			    // 파일 추가/미리보기 로우 추가
				$(`<tr id="imageInputRow">
						<th>이미지 업로드</th>
						<td>
							<input type="file" class="imageInput" accept="image/jpeg,image/png,image/gif,image/bmp,image/svg+xml"/>
						</td>
				   </tr>`).insertAfter('#qInputRow');
				$(`<tr id="imagePreviewRow">
						<th>미리보기</th>
						<td><img class="imagePreview" style="max-width:200px; max-height:200px; display:block"/></td>
				   </tr>`).insertAfter('#imageInputRow');
			    
			    // 객관식 타입이면 옵션 입력/목록 로우 추가
			    if(type === 'radio' || type === 'dropdown' || type === 'check') {
					$(`<tr id="optionInputRow">
					        <th>응답 옵션</th>
					        <td>
					          <input type="text" id="optionContent" style="width:70%"/>
					          <button type="button" id="addOptionBtn">추가</button>
					        </td>
					      </tr>`).insertAfter('#imagePreviewRow'); // imagePreviewRow 다음에 추가
					$(`<tr id="optionListRow">
					        <th>옵션 리스트</th>
					        <td><ul id="optionList" style="list-style:none;padding:0;margin:0"></ul></td>
					      </tr>`).insertAfter('#optionInputRow'); // optionInputRow 다음에 추가
			    }
			}
			
			// 옵션 리스트 렌더링
			function renderOptionList() {
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
			function renderQuestionList() {
				var $list = $('#questionList').empty();
				questions.forEach((q, idx) => {
					var label = typeLabels[q.type] || typeLabels.short;
					var requiredMark;
					if(q.isRequired) {
						requiredMark = '<span id="required-mark">＊</span>';
					} else {
						requiredMark = '';
					}
					
				    // HTML 이스케이프 (XSS 예방 차원)
				    var escaped = q.content.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
				    // 줄바꿈을 <br/> 로 변환
				    var contentHtml = escaped.replace(/\r\n|\r|\n/g, '<br/>');
					
					var $tbl = $(`
						<table class="question-item" data-index="\${idx}" >
							<tr>
								<th colspan="2">
									<div class="th-content">
										<span class="label-text">Q\${idx+1}. \${label} 질문 \${requiredMark}</span>
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
								<td>\${contentHtml}</td>
							</tr>
						</table>`);
					// 이미지데이터가 있으면 아래에 로우 추가
					if(q.imageData) {
						$tbl.append(`<tr><th>첨부 이미지</th><td><img src="\${q.imageData}" style="max-width:200px;"/></td></tr>`);
					}
					// 질문이 객관식 타입이면 아래에 로우 추가
					if(q.type === 'radio' || q.type === 'dropdown' || q.type === 'check') {
						var optsHtml = q.qitemList.map(o=>`<div>▪ \${o}</div>`).join('');
						$tbl.append(`<tr><th>응답 옵션</th><td>\${optsHtml}</td></tr>`);
					}
					$list.append($tbl);
				});
			}
			
			// 질문 추가 버튼
			$('#addBtn').on('click', function() {
				var type = $('#qTypeSelect').val();
				var content = $('#qContent').val()?.trim();
				var isRequired = $('#isRequiredSwitch').prop('checked');
				if(!content) {
					alert('질문을 입력해주세요');
					return;
				}
				var qObj = { type, content, isRequired };
				// 타입이 객관식이면 옵션 필수 체크
			    if(type === 'radio' || type === 'dropdown' || type === 'check') {
					if(currentOptions.length<1) return alert('옵션을 하나 이상 추가해주세요');
					qObj.qitemList = [...currentOptions];
				}
				// 이미지 있으면 이미지 파일 필수 체크
			    if(currentImage) {
					qObj.imageFile = currentImage; // 서버 전송용
					qObj.imageData = currentImageData; // 미리보기용
				}
				// 새 질문 객체 push
				questions.push(qObj);
				renderQuestionList();
				resetForm();
			});
			
			// 수정 모드로 진입
			$('#questionList').on('click', '.modifyBtn', function() {
				var idx = +$(this).closest('table').data('index');
				// 다른 질문 수정 중이면 차단
			    if (editingIndex !== null) {
			    	alert('현재 ' + (editingIndex+1) + '번 질문을 수정 중입니다! 먼저 수정 완료를 눌러주세요.');
			        return false;
			    }
				editingIndex = idx;
				var q = questions[idx];
				
				$('#qHint').text('설문지 질문 수정(Q' + (editingIndex+1) + ')');
				
				// 질문아이템의 필수 여부 값 스위치 세팅
				$('#isRequiredSwitch').prop('checked', q.isRequired);
				// 폼에 값 채워주기
				$('#qTypeSelect').val(q.type);
				renderTypeForm(q.type);
				$('#qContent').val(q.content);
				// 객관식이면 기존 옵션들 세팅
				if (q.qitemList) {
					currentOptions = [...q.qitemList];
					renderOptionList();
				}
				// 이미지면 해당 이미지 세팅
				if (q.imageData) {
					var $td = $('#imagePreviewRow td');
					if (!$('#removeImageBtn').length) {
						$('<button type="button" id="removeImageBtn">이미지 제거</button>').appendTo($td).on('click', function() {
							// 이미지 삭제 로직
							currentImage = null;
							currentImageData = null;
							$('.imagePreview').attr('src','');
							$('.imageInput').val('');
		                    q.imageData = null;
		                    q.imageFile = null;
							$(this).remove();
						});
					}
					currentImage = q.imageFile || null;
					currentImageData = q.imageData;
					$('.imagePreview').attr('src', currentImageData);
				}
				
				// 추가 버튼 숨기고 수정완료 버튼 추가
				$('#addBtn').hide();
				if(!$('#saveBtn').length) {
					$('#addQuestionTable tr:first th #qAddHeader')
					  .append(' <button type="button" id="saveBtn">수정완료</button>');
				}
				
				// 자동 스크롤 애니메이션
				var targetScroll = $(document).height() - $(window).height();
				$('html, body').animate({ scrollTop: targetScroll }, 500, 'swing');
				
				// 수정완료 클릭 핸들러
				$('#saveBtn').off('click').on('click', function() {
					$('#qHint').text('설문지 질문 추가');
					var newType = $('#qTypeSelect').val();
					var newContent = $('#qContent').val()?.trim();
					var newIsRequired = $('#isRequiredSwitch').prop('checked');
					var originalIdx = q.idx;
					if(!newContent){
						alert('질문을 입력해주세요');
						return;
					}
					// 배열 업데이트(객관식일경우 옵션리스트 객체를 배열에 추가)
					var updated = { idx: originalIdx, type: newType, content: newContent, isRequired: newIsRequired };
					if(newType === 'radio' || newType === 'dropdown' || newType === 'check') {
						if(currentOptions.length<1) return alert('옵션을 하나 이상 추가해주세요');
						updated.qitemList = [...currentOptions];
					}
					// 이미지 파일이 있으면 추가
					if(currentImage) {
						updated.imageData = currentImageData;
						updated.imageFile = currentImage;
					} else if (q.imageData) {
						updated.imageData = q.imageData; // 이미지 변경 안했으면 그대로 유지
					}
					questions[idx] = updated;
					renderQuestionList();
					resetForm();
					editingIndex = null;
					
					// 해당 질문 아이템 위치로 스크롤 이동하고 효과
				    var $target = $('#questionList').find('.question-item').eq(idx);
				    if ($target.length) {
				        $('html, body').animate({
				            scrollTop: $target.offset().top
				        }, 500, 'swing', function() {
				        	var $hdr = $target.find('.th-content').first();
				            $hdr.addClass('highlight-wave');
				            setTimeout(function(){
				                $hdr.removeClass('highlight-wave');
				            }, 600);
				        });
				    }
				});
			});
			
			// 질문 삭제
			$('#questionList').on('click', '.deleteBtn', function() {
				var idx = +$(this).closest('table').data('index');
				// 다른 질문 편집 중이면 차단
			    if (editingIndex !== null) {
			    	alert('현재 ' + (editingIndex+1) + '번 질문을 수정 중입니다! 먼저 수정 완료를 눌러주세요.');
			        return false;
			    }
				questions.splice(idx, 1);
				renderQuestionList();
			});
			
			// 질문 순서 올리기
			$('#questionList').on('click', '.upBtn', function() {
				var idx = +$(this).closest('table').data('index');
				// 다른 질문 편집 중이면 차단
			    if (editingIndex !== null) {
			        alert('현재 ' + (editingIndex+1) + '번 질문을 수정 중입니다! 먼저 수정 완료를 눌러주세요.');
			        return false;
			    }
				if(idx > 0) {
					[questions[idx-1], questions[idx]] = [questions[idx], questions[idx-1]];
					renderQuestionList();
				}
			});
			
			// 질문 순서 내리기
			$('#questionList').on('click', '.downBtn', function() {
				var idx = +$(this).closest('table').data('index');
				// 다른 질문 편집 중이면 차단
			    if (editingIndex !== null) {
			    	alert('현재 ' + (idx+1) + '번 질문을 수정 중입니다! 먼저 수정 완료를 눌러주세요.');
			        return false;
			    }
				if(idx < questions.length - 1) {
					[questions[idx], questions[idx+1]] = [questions[idx+1], questions[idx]];
					renderQuestionList();
				}
			});
			
			// 옵션 추가
			$('#addQuestionTable').on('click', '#addOptionBtn', function() {
				var opt = $('#optionContent').val()?.trim();
				if(!opt) return alert('옵션을 입력해주세요');
				currentOptions.push(opt);
				renderOptionList();
				$('#optionContent').val('').focus();
			});
			
			// 옵션 삭제
			$('#addQuestionTable').on('click','.optDelBtn', function() {
				var i = +$(this).parent().data('idx');
				currentOptions.splice(i,1);
				renderOptionList();
			});
			
			// 옵션 순서 올리기
			$('#addQuestionTable').on('click','.optUpBtn', function() {
				var i = +$(this).parent().data('idx');
				if (i > 0) {
					[currentOptions[i-1],currentOptions[i]] = [currentOptions[i],currentOptions[i-1]];
					renderOptionList();
				}
			});
			
			// 옵션 순서 내리기
			$('#addQuestionTable').on('click','.optDownBtn', function() {
				var i = +$(this).parent().data('idx');
				if(i < currentOptions.length-1) {
					[currentOptions[i],currentOptions[i+1]] = [currentOptions[i+1],currentOptions[i]];
					renderOptionList();
				}
			});
			
			// 이미지 파일 선택 시 검증 + 미리보기
			$('#addQuestionTable').on('change','.imageInput',function() {
				var file = this.files[0];
				if(file) {
				    // 허용할 확장자 리스트
				    var allowed = ['jpg','jpeg','png','gif','bmp','svg'];
				    var ext = file.name.split('.').pop().toLowerCase();
					if(allowed.indexOf(ext) < 0) {
						alert('지원하지 않는 파일 형식입니다. JPG, PNG, GIF, BMP, SVG만 가능합니다.');
						$(this).val('');
						return;
					}
				    if (!file.type.startsWith('image/')) {
				        alert('이미지 파일이 아닙니다');
				        $(this).val('');
				        return;
				    }
					currentImage = file;
					var reader = new FileReader();
					reader.onload = function(e) {
						currentImageData = e.target.result;
						$('.imagePreview').attr('src', e.target.result);
						
					    var $td = $('#imagePreviewRow td');
					    if (!$('#removeImageBtn').length) {
							$('<button type="button" id="removeImageBtn">이미지 제거</button>').appendTo($td).on('click', function() {
								// 클릭하면 이미지·파일 초기화
								currentImage = null;
								currentImageData = null;
								$('.imagePreview').attr('src', '');
								$('.imageInput').val('');
								$(this).remove();
							});
					    }
					};
					reader.readAsDataURL(file);
				}
			});
			
			$('#checkArray').on('click', function() {
				console.table(questions);
				console.log(JSON.stringify(questions));
			});
	    	
	    	/* --------------------------- 질문 리스트 관련 스크립트 끝 --------------------------------- */
			
	    	
	        $('#btnSubmit').click(function(e){
	        	// 폼 검증(하나라도 인풋이 비어있으면 알림)
	    		if (!$('#title')[0].reportValidity()) return;
	    		if (!$('#description')[0].reportValidity()) return;
	    		
	    		if (questions.length === 0) {
	    			alert("질문을 한개 이상 등록하셔야 합니다.");
	    			return;
	    		}
	    		
				// Date 객체로 가져오기
				var startObj = $("#datepickerStart").datepicker("getDate");
				var endObj   = $("#datepickerEnd").datepicker("getDate");
				// 종료 날짜가 시작날짜보다 빠른지 체크
				if (endObj < startObj) {
					alert("종료일이 시작일보다 빠릅니다! 날짜를 다시 확인해주세요");
					return;
				}
				// 문자열 포맷 변환
				var startStr = $.datepicker.formatDate("yy-mm-dd", startObj) + "T00:00:00+09:00";
				var endStr = $.datepicker.formatDate("yy-mm-dd", endObj) + "T00:00:00+09:00";
				
				// 사용 여부 값 가져오기
				var isUseVal = $('input[name="isUse"]:checked').val() === 'true';
				
				// questions 배열에서 imageFile, imageData 필드 뺀 clone 배열 준비
				var cleanQuestions = questions.map(q => {
					var { idx, type, content, isRequired, qitemList } = q;
					return { idx, type, content, isRequired, ...(qitemList && { qitemList: qitemList.map((opt) => ({ content: opt })) }), imageChanged: !!q.imageFile };
				});
				
				// 비교용 원본 배열 준비
				if (mode === 'edit') {
					var cleanOriginQuestions = JSON.parse(originQuestions).map(q => {
						var { idx, type, content, isRequired, qitemList } = q;
						return { idx, type, content, isRequired, ...(qitemList && { qitemList: qitemList.map((opt) => ({ content: opt })) }), imageChanged: !!q.imageFile };
					});
				}

	        	// 설문에 응답 이력이 있고 질문이 변경되었으면 차단
				if (mode==='edit' && hasResponded) {
					if (JSON.stringify(cleanQuestions) !== JSON.stringify(cleanOriginQuestions)) {
						alert('해당 설문에 이미 응답 이력이 있어 질문을 수정할 수 없습니다. 설문 메타데이터만 변경 가능합니다.');
						e.preventDefault();
						return false;
					}
				}
				
	    		// 검증 통과 시 게시글 등록/수정 api 실행
	    		var payload = {
	    				survey: $.extend({}, {
		    				authorIdx: sessionUserIdx,
		    				editorIdx: sessionUserIdx,
		    				title: $('#title').val(),
		    				description: $('#description').val(),
		    				startDate: startStr,
		    				endDate: endStr,
		    				isUse: isUseVal
	    				}, mode==='edit'?{idx: idx}:{}),
	    				questionList: cleanQuestions
   				}; // 보낼 데이터
	    		console.log("payload: " + JSON.stringify(payload));
   				
				// FormData 에 JSON + 이미지 파일들 묶기
				var formData = new FormData();
				formData.append('payload', new Blob([JSON.stringify(payload)],{type:'application/json'}));
				questions.forEach(q => {
					if (q.imageFile) {
						// 키는 전부 동일하게 'files' 로, 순서대로 붙이면 컨트롤러에 List<MultipartFile> 로 들어옴
						formData.append('files', q.imageFile);
					}
				});
				
				for (let [key, value] of formData.entries()) {
					console.log(key, value);
				}
	    		
	    		// 설문지 등록 요청
	    		$.ajax({
	    			url: apiUrl,
	    			type:'POST',
	    			contentType: false,
	    			processData: false,
	    			dataType: 'json',
	    			data: formData,
	    			success: function(res){
						if (res.error) {
							alert(res.error);
						} else {
							alert(mode==='edit'?'설문 수정 완료':'설문 등록 완료');
							postTo('${surveyManageUrl}', { searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
			            }
	    			},
					error: function(xhr){
						// 네트워크 연결 리셋 시 (멀티파트 파일들 크기가 제한 크기보다 크면 발생)
						if (xhr.status === 0) {
							alert("이미지 파일 크기가 너무 커서 서버 연결이 리셋됐습니다. 파일 크기를 확인해주세요.");
							return;
						}
						var errMsg = xhr.responseJSON && xhr.responseJSON.error; // 인터셉터에서 에러메시지 받아옴
						if (!errMsg) {
							try {
								errMsg = JSON.parse(xhr.responseText).error;
							} catch (e) {
								errMsg = '설문 ' + (mode==='edit'?'수정':'등록') + ' 중 에러 발생'
							}
						}
						alert(errMsg);
					}
	    		});
	        });
	    	
	        $('#btnDelete').click(function() {
	        	if (isAdmin != 'true') {
	        		alert('삭제 권한이 없습니다');
	        		return;
	        	}
	        	if (!confirm('정말 삭제하시겠습니까?')) return;
				$.ajax({
					url: '${deleteApi}',
					type: 'POST',
					contentType: 'application/json',
					data: JSON.stringify({ idx: idx }),
					success: function(res) {
						if (res.error) {
							alert(res.error);
						} else {
							alert('설문 삭제가 완료되었습니다');
							postTo('${surveyManageUrl}', { searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
						}
					}
				})
	        	
			})
	    	
	    	$('#btnCancel').click(function() {
	    		// 설문 목록 페이지 이동
	    		postTo('${surveyManageUrl}', { searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
	    	});
	    	
	    });
	</script>
</body>
</html>
package egovframework.third.homework.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.third.homework.service.AnswerService;
import egovframework.third.homework.service.QimageService;
import egovframework.third.homework.service.QimageVO;
import egovframework.third.homework.service.QitemService;
import egovframework.third.homework.service.QitemVO;
import egovframework.third.homework.service.QuestionService;
import egovframework.third.homework.service.QuestionVO;
import egovframework.third.homework.service.SurveyResponseService;
import egovframework.third.homework.service.SurveyService;
import egovframework.third.homework.service.SurveyVO;


//Service 구현체
@Service("surveyService")
public class SurveyServiceImpl extends EgovAbstractServiceImpl implements SurveyService {

	// 로거
	private static final Logger log = LoggerFactory.getLogger(SurveyServiceImpl.class);
	
	@Resource(name = "surveyDAO")
	private SurveyDAO surveyDAO;
	
    @Resource(name = "questionService")
    private QuestionService questionService;
    
    @Resource(name="qitemService")
    private QitemService qitemService;
    
    @Resource(name="qimageService")
    private QimageService qimageService;
    
    @Resource(name="answerService")
    private AnswerService answerService;
    
    @Resource(name="surveyResponseService")
    private SurveyResponseService surveyResponseService;

	// 설문 등록(해당 설문의 질문과 문항/이미지 등록 작업 포함)
	@Override
	public void createSurvey(SurveyVO vo, List<QuestionVO> questionList, List<MultipartFile> files) throws Exception {
		surveyDAO.insertSurvey(vo); // 설문 먼저 등록
		int imgIdx = 0; // 이미지
		log.info("INSERT 설문 등록 시도중.. idx: {}", vo.getIdx());
		// 질문들 등록
		if (questionList != null) {
			for (int i = 0; i < questionList.size(); i++) {
				QuestionVO q = questionList.get(i);
				q.setSurveyIdx(vo.getIdx()); // surveyIdx를 해당 설문 idx로 설정
				q.setSeq(i); // 순서값 세팅
				questionService.createQuestion(q); // 질문 등록
				
				// 객관식 문항 처리
				if (q.getQitemList() != null) {
					for (int j = 0; j < q.getQitemList().size(); j++) {
						QitemVO qitem = new QitemVO();
						qitem.setQuestionIdx(q.getIdx()); // questionIdx를 해당 질문 idx로 설정
						qitem.setContent(q.getQitemList().get(j).getContent());
						qitem.setSeq(j);
						qitemService.createQitem(qitem);
					}
				}
				if (Boolean.TRUE.equals(q.getImageChanged())) {
					// imgIdx 해당하는 파일이 존재하면 질문에 imgidx로 파일 매핑
					if (files != null && imgIdx < files.size() && !files.get(imgIdx).isEmpty()) {
						MultipartFile mf = files.get(imgIdx++);
						qimageService.createQimage(q.getIdx(), mf); // 이미지를 해당 질문 자식으로 저장
					}
				}
			}
		}
		log.info("설문 등록 성공!");
	}

	// 설문 목록 조회
	@Override
	public List<SurveyVO> getSurveyList(SurveyVO vo, String searchType, String searchKeyword, Boolean onlyAvailable) throws Exception {
        Map<String,Object> param = new HashMap<>();
        param.put("surveyVO", vo);
        param.put("searchType", searchType);
        param.put("searchKeyword", searchKeyword);
        param.put("onlyAvailable", onlyAvailable);
		return surveyDAO.selectSurveyList(param);
	}
	
	// 전체/검색된 설문 개수 조회
	@Override
	public int getSurveyCount(SurveyVO vo, String searchType, String searchKeyword, Boolean onlyAvailable) throws Exception {
        Map<String,Object> param = new HashMap<>();
        param.put("surveyVO", vo);
        param.put("searchType", searchType);
        param.put("searchKeyword", searchKeyword);
        param.put("onlyAvailable", onlyAvailable);
		return surveyDAO.selectSurveyCount(param);
	}

	// 설문 상세 조회
	@Override
	public SurveyVO getSurvey(String idx) throws Exception {
		return surveyDAO.selectSurvey(idx);
	}

	// 설문 수정
	@Override
	public void modifySurvey(SurveyVO vo, List<QuestionVO> questionList, List<MultipartFile> files) throws Exception {
		surveyDAO.updateSurvey(vo); // 설문 먼저 수정
		log.info("UPDATE 설문 수정 시도중.. idx: {}", vo.getIdx());
		
		int imgIdx = 0; // 이미지
		
		// 기존 질문들 중, 수정자가 보내주지 않은 질문은 삭제 처리
		// questionList에 있는 idx를 incomingIdxs에 모아두기
		List<String> incomingIdxs = new ArrayList<>();
		for (QuestionVO q : questionList) {
			if (q.getIdx() != null) {
				incomingIdxs.add(q.getIdx());
			}
		}
		
		// DB에 있는 기존 질문 리스트
		List<QuestionVO> existingQList = questionService.getQuestionList(vo.getIdx());
		for (QuestionVO originQ : existingQList) {
			// incomingIdxs에 원래 질문의 idx가 없으면 삭제할 질문임
			if (!incomingIdxs.contains(originQ.getIdx())) {
				// 문항/이미지 삭제 후 질문 삭제
				List<QitemVO> items = qitemService.getQitemList(originQ.getIdx());
				for (QitemVO qi : items) {
					qitemService.removeQitem(qi.getIdx());
				}
				QimageVO img = qimageService.getQimageByQuestionIdx(originQ.getIdx());
				if (img != null) {
					qimageService.removeQimage(img.getIdx());
				}
	            questionService.removeQuestion(originQ.getIdx());
			}
		}
		
		// 기존 + 신규 질문들 처리
		for (int i = 0; i < questionList.size(); i++) {
			QuestionVO q = questionList.get(i);
			q.setSurveyIdx(vo.getIdx()); // surveyIdx를 해당 설문 idx로 설정
			q.setSeq(i); // 순서값 세팅
			
			if (q.getIdx() == null) {
				// 아직 pk가 없으니 신규 질문임
				questionService.createQuestion(q); // 신규 질문 등록
			} else {
				// 질문 변경사항 있는지 체크
				QuestionVO originQ = questionService.getQuestion(q.getIdx());
			    boolean contentChanged = !originQ.getContent().equals(q.getContent());
			    boolean requiredChanged = originQ.getIsRequired() != q.getIsRequired();
			    boolean typeChanged = !originQ.getType().equals(q.getType());
			    
			    if (contentChanged || requiredChanged || typeChanged) {
			    	questionService.modifyQuestion(q); // 기존 질문 업데이트
			    }
			}
			
			// 객관식 문항은 전부 삭제하고 재등록
			if (q.getType().equals("radio") || q.getType().equals("dropdown") || q.getType().equals("check")) {
				// 기존 문항과 새 문항 비교
	            List<QitemVO> existingItems = qitemService.getQitemList(q.getIdx());
	            List<String> existingContents = new ArrayList<>(); // 기존 문항 내용 리스트
	            for (QitemVO ei : existingItems) {
	                existingContents.add(ei.getContent());
	            }
	            List<String> newContents = new ArrayList<>(); // 새 문항 내용 리스트
	            if (q.getQitemList() != null) {
	            	for (QitemVO item : q.getQitemList()) {
	            		newContents.add(item.getContent());
	            	}
	            }
	            
	            if (!existingContents.equals(newContents)) {
					// 질문 q의 문항 전부 삭제
					for (QitemVO ei : existingItems) {
						qitemService.removeQitem(ei.getIdx());
					}
					// 객관식 문항 일괄 등록
					if (q.getQitemList() != null) {
						for (int j = 0; j < newContents.size(); j++) {
							QitemVO qitem = new QitemVO();
							qitem.setQuestionIdx(q.getIdx()); // questionIdx를 해당 질문 idx로 설정
							qitem.setContent(newContents.get(j));
							qitem.setSeq(j);
							qitemService.createQitem(qitem);
						}
					}
	            }
			}
			
			// 이미지도 기존 삭제하고 재등록
			if (Boolean.TRUE.equals(q.getImageChanged())) {
			    // 기존 이미지 조회
			    QimageVO exist = qimageService.getQimageByQuestionIdx(q.getIdx());

			    // 프론트에서 실제 새 파일이 넘어왔을 때만
			    if (files != null && imgIdx < files.size() && !files.get(imgIdx).isEmpty()) {
			        // 기존 이미지 삭제
			        if (exist != null) {
			            qimageService.removeQimage(exist.getIdx());
			        }
			        // 새 파일 등록
			        MultipartFile mf = files.get(imgIdx++);
			        qimageService.createQimage(q.getIdx(), mf);
			    }
			}
		}
		log.info("설문 수정 성공!");
	}

	// 설문 삭제 + 질문 삭제 + 문항 삭제 + 이미지 삭제 + 설문 응답 기록 삭제 + 설문 답변 삭제
	@Override
	public void removeSurvey(String idx) throws Exception {
		log.info("DELETE 설문({}) 삭제 시도중...", idx);
		// 먼저 설문 응답 기록부터 삭제
		surveyResponseService.removeSurveyResponseList(idx);
		
		// 질문들 삭제
		List<QuestionVO> questions = questionService.getQuestionList(idx); // 질문 목록 가져오기
		for (QuestionVO q : questions) {
			answerService.removeAnswerList(q.getIdx()); // 질문의 모든 답변 삭제
			QimageVO image = qimageService.getQimageByQuestionIdx(q.getIdx());
			if (image != null) {
				qimageService.removeQimage(image.getIdx()); // 질문의 이미지 삭제
			}
			List<QitemVO> qitems = qitemService.getQitemList(q.getIdx());
			if (!qitems.isEmpty()) {
				for (QitemVO qi : qitems) {
					qitemService.removeQitem(qi.getIdx()); // 질문의 문항 전부 삭제
				}
			}
			questionService.removeQuestion(q.getIdx()); // 질문 삭제
		}
		surveyDAO.deleteSurvey(idx); // 설문 삭제
		log.info("설문 삭제 성공!");
	}
	 
}

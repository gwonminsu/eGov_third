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

import egovframework.third.homework.service.QimageService;
import egovframework.third.homework.service.QimageVO;
import egovframework.third.homework.service.QitemService;
import egovframework.third.homework.service.QitemVO;
import egovframework.third.homework.service.QuestionService;
import egovframework.third.homework.service.QuestionVO;
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

	// 설문 등록(해당 설문의 질문과 문항/이미지 등록 작업 포함)
	@Override
	public void createSurvey(SurveyVO vo, List<QuestionVO> questionList, List<MultipartFile> files) throws Exception {
		surveyDAO.insertSurvey(vo); // 설문 먼저 등록
		log.info("INSERT 설문 등록 성공 idx: {}", vo.getIdx());
		int imgIdx = 0; // 이미지
		
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
						qitem.setContent(q.getQitemList().get(j));
						qitem.setSeq(j);
						qitemService.createQitem(qitem);
					}
				}
				
				// 여기에 질문 타입 이미지에 imgidx로 파일 매핑
				if (q.getType().equals("image")) {
					MultipartFile mf = files.get(imgIdx++);
					qimageService.createQimage(q.getIdx(), mf); // 이미지를 해당 질문 자식으로 저장
				}
			}
		}
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
		log.info("UPDATE 설문 수정 성공 idx: {}", vo.getIdx());
		
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
				questionService.modifyQuestion(q); // 기존 질문 업데이트
			}
			
			// 객관식 문항은 전부 삭제하고 재등록
			if (q.getType().equals("radio") || q.getType().equals("dropdown") || q.getType().equals("check")) {
				// 질문 q의 문항 전부 삭제
				List<QitemVO> items = qitemService.getQitemList(q.getIdx());
				for (QitemVO qitem : items) {
					qitemService.removeQitem(qitem.getIdx());
				}
				// 객관식 문항 일괄 등록
				if (q.getQitemList() != null) {
					for (int j = 0; j < q.getQitemList().size(); j++) {
						QitemVO qitem = new QitemVO();
						qitem.setQuestionIdx(q.getIdx()); // questionIdx를 해당 질문 idx로 설정
						qitem.setContent(q.getQitemList().get(j));
						qitem.setSeq(j);
						qitemService.createQitem(qitem);
					}
				}
			}
			
			// 이미지도 기존 삭제하고 재등록
			if (q.getType().equals("image") && Boolean.TRUE.equals(q.getImageChanged())) {
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
	}

	// 설문 삭제
	@Override
	public void removeSurvey(String idx) throws Exception {
		surveyDAO.deleteSurvey(idx);
	}
	 
}

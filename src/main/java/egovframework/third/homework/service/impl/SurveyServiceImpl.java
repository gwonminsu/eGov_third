package egovframework.third.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

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

	// 설문 등록(해당 설문의 질문 등록 작업 포함)
	@Override
	public void createSurvey(SurveyVO vo, List<QuestionVO> questionList) throws Exception {
		surveyDAO.insertSurvey(vo); // 설문 먼저 등록
		log.info("INSERT 설문 등록 성공 idx: {}", vo.getIdx());
		
		// 질문들 등록
		if (questionList != null) {
			for (int i = 0; i < questionList.size(); i++) {
				QuestionVO q = questionList.get(i);
				q.setSurveyIdx(vo.getIdx()); // surveyIdx를 해당 설문 idx로 설정
				q.setSeq(i); // 순서값 세팅
				questionService.createQuestion(q); // 질문 등록
			}
		}
	}

	// 설문 목록 조회
	@Override
	public List<SurveyVO> getSurveyList() throws Exception {
		return surveyDAO.selectSurveyList();
	}

	// 설문 상세 조회
	@Override
	public SurveyVO getSurvey(String idx) throws Exception {
		return surveyDAO.selectSurvey(idx);
	}

	// 설문 수정
	@Override
	public void modifySurvey(SurveyVO vo) throws Exception {
		surveyDAO.updateSurvey(vo);
		
	}

	// 설문 삭제
	@Override
	public void removeSurvey(String idx) throws Exception {
		surveyDAO.deleteSurvey(idx);
	}
	 
}

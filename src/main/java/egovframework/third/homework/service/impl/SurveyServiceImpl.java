package egovframework.third.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.third.homework.service.SurveyService;
import egovframework.third.homework.service.SurveyVO;


//Service 구현체
@Service("surveyService")
public class SurveyServiceImpl extends EgovAbstractServiceImpl implements SurveyService {

	// 로거
	private static final Logger log = LoggerFactory.getLogger(SurveyServiceImpl.class);
	
	@Resource(name = "surveyDAO")
	private SurveyDAO surveyDAO;

	// 설문 등록
	@Override
	public void createSurvey(SurveyVO vo) throws Exception {
		surveyDAO.insertSurvey(vo);
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

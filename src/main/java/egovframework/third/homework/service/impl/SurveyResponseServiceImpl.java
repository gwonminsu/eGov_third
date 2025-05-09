package egovframework.third.homework.service.impl;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.third.homework.service.SurveyResponseService;
import egovframework.third.homework.service.SurveyResponseVO;

@Service("surveyResponseService")
public class SurveyResponseServiceImpl extends EgovAbstractServiceImpl implements SurveyResponseService {

	private static final Logger log = LoggerFactory.getLogger(SurveyResponseServiceImpl.class);
	
	@Resource(name = "surveyResponseDAO")
	private SurveyResponseDAO sResDAO;
	
	// 사용자 설문 응답 여부 조회
	@Override
	public boolean hasResponded(String surveyIdx, String userIdx) throws Exception {
		Map<String,String> param = new HashMap<>();
        param.put("surveyIdx", surveyIdx);
        param.put("userIdx", userIdx);
		int count = sResDAO.countBySurveyAndUser(param);
		boolean hasResponded = count > 0;
		log.info("SELECT 설문({})에 대한 사용자({})의 응답여부 조회 완료: {}", surveyIdx, userIdx, hasResponded);
		return hasResponded;
	}
	
	// 설문 idx로 설문에 응답한 기록들 전부 삭제
	@Override
	public void removeSurveyResponseList(String surveyIdx) throws Exception {
		sResDAO.deleteSurveyResponseBySurveyIdx(surveyIdx);
		log.info("DELETE 설문({})에 응답한 기록들 삭제 완료", surveyIdx);
	}

}

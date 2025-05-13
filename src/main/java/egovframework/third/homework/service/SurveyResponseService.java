package egovframework.third.homework.service;

import java.util.List;

//Service 인터페이스
public interface SurveyResponseService {

	// 사용자 설문 응답 여부 조회
	boolean hasResponded(String surveyIdx, String userIdx) throws Exception;
	
	// 설문에 응답한 기록 목록 조회
	List<SurveyResponseVO> getSurveyResponseList(String surveyIdx) throws Exception;
	
	// 설문 idx로 설문에 응답한 기록들 전부 삭제
    void removeSurveyResponseList(String surveyIdx) throws Exception;
    
}

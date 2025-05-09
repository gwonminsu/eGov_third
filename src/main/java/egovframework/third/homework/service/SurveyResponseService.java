package egovframework.third.homework.service;

//Service 인터페이스
public interface SurveyResponseService {

	// 설문 idx로 설문에 응답한 기록들 전부 삭제
    void removeSurveyResponseList(String surveyIdx) throws Exception;
    
}

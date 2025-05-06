package egovframework.third.homework.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

//Service 인터페이스
public interface SurveyService {

	// 설문 등록(해당 설문의 질문 등록 작업 포함)
    void createSurvey(SurveyVO vo, List<QuestionVO> questionList, List<MultipartFile> files) throws Exception;
    
    // 설문 리스트 조회
    List<SurveyVO> getSurveyList(SurveyVO vo, String searchType, String searchKeyword, Boolean onlyAvailable) throws Exception;
    
    // 전체/검색된 설문 개수 조회
    int getSurveyCount(SurveyVO vo, String searchType, String searchKeyword, Boolean onlyAvailable) throws Exception;
    
    // 설문 상세 조회
    SurveyVO getSurvey(String idx) throws Exception;
    
    // 설문 수정
    void modifySurvey(SurveyVO vo) throws Exception;
    
    // 설문 삭제
    void removeSurvey(String idx) throws Exception;
    
}

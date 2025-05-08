package egovframework.third.homework.service;

import java.util.List;

//Service 인터페이스
public interface AnswerService {

	// 설문의 모든 질문에 대한 답변들 일괄 등록
    void createAnswerList(SurveyResponseVO resp, List<AnswerVO> answers) throws Exception;
    
    // 질문에 달린 답변 목록 조회
    List<AnswerVO> getAnswerList(String questionIdx) throws Exception;
    
    // 답변 단일 조회
    AnswerVO getAnswer(String idx) throws Exception;
    
}

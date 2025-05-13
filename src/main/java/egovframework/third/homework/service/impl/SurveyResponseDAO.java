package egovframework.third.homework.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.third.homework.service.SurveyResponseVO;

@Repository("surveyResponseDAO")
public class SurveyResponseDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 설문 응답 기록 등록
	public void insertSurveyResponse(SurveyResponseVO vo) throws Exception {
		sqlSession.insert("surveyResponseDAO.insertSurveyResponse", vo);
	}
    
    // 설문 응답 기록 단일 조회
    public SurveyResponseVO selectSurveyResponse(String idx) throws Exception {
        return sqlSession.selectOne("surveyResponseDAO.SurveyResponse", idx);
    }
    
    // 설문에 응답한 기록 목록 조회
    public List<SurveyResponseVO> selectSurveyResponseListBySurveyIdx(String surveyIdx) throws Exception {
    	return sqlSession.selectList("surveyResponseDAO.selectSurveyResponseListBySurveyIdx", surveyIdx);
    }
    
    // 사용자 설문 응답 여부 조회
    public int countBySurveyAndUser(Map<String,String> param) throws Exception {
    	int count = sqlSession.selectOne("surveyResponseDAO.countBySurveyAndUser", param);
    	return count;
    }
    
    // 설문조사 idx에 해당하는 응답 기록 삭제
    public void deleteSurveyResponseBySurveyIdx(String surveyIdx) throws Exception {
    	sqlSession.delete("surveyResponseDAO.deleteSurveyResponseBySurveyIdx", surveyIdx);
    }
    
}

package egovframework.third.homework.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.third.homework.service.SurveyVO;

@Repository("surveyDAO")
public class SurveyDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 설문 등록
	public void insertSurvey(SurveyVO vo) throws Exception {
		sqlSession.insert("surveyDAO.insertSurvey", vo);
	}
    
    // 설문 목록 조회
    public List<SurveyVO> selectSurveyList(Map<String,Object> param) throws Exception {
        return sqlSession.selectList("surveyDAO.selectSurveyList", param);
    }
    
    // 전체/검색한 설문 개수 조회
    public int selectSurveyCount(Map<String,Object> param) throws Exception {
    	return sqlSession.selectOne("surveyDAO.selectSurveyCount", param);
    }
    
    // 설문 상세 조회
    public SurveyVO selectSurvey(String idx) throws Exception {
        return sqlSession.selectOne("surveyDAO.selectSurvey", idx);
    }
    
    // 설문 수정
    public void updateSurvey(SurveyVO vo) throws Exception {
        sqlSession.update("surveyDAO.updateSurvey", vo);
    }
    
    // 설문 삭제
    public void deleteSurvey(String idx) throws Exception {
        sqlSession.delete("surveyDAO.deleteSurvey", idx);
    }
}

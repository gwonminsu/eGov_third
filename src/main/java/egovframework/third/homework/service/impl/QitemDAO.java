package egovframework.third.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.third.homework.service.QitemVO;

@Repository("qitemDAO")
public class QitemDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 질문 등록
	public void insertQitem(QitemVO vo) throws Exception {
		sqlSession.insert("qitemDAO.insertQitem", vo);
	}
    
    // 질문 idx로 질문 목록 조회
    public List<QitemVO> selectQitemListByQuestionIdx(String questionIdx) throws Exception {
        return sqlSession.selectList("qitemDAO.selectQitemListByQuestionIdx", questionIdx);
    }
    
    // 질문 단일 조회
    public QitemVO selectQitem(String idx) throws Exception {
        return sqlSession.selectOne("qitemDAO.selectQitem", idx);
    }
    
    // 질문 수정
    public void updateQitem(QitemVO vo) throws Exception {
        sqlSession.update("qitemDAO.updateQitem", vo);
    }
    
    // 질문 삭제
    public void deleteQitem(String idx) throws Exception {
        sqlSession.delete("qitemDAO.deleteQitem", idx);
    }
}

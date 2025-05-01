package egovframework.third.homework.service;

import java.util.List;

//Service 인터페이스
public interface QitemService {

	// 문항 등록
    void createQitem(QitemVO vo) throws Exception;
    
    // 질문에 소속된 문항 리스트 조회
    List<QitemVO> getQitemList(String questionIdx) throws Exception;
    
    // 문항 단일 조회
    QitemVO getQitem(String idx) throws Exception;
    
    // 문항 수정
    void modifyQitem(QitemVO vo) throws Exception;
    
    // 문항 삭제
    void removeQitem(String idx) throws Exception;
    
}

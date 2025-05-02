package egovframework.third.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.third.homework.service.QitemService;
import egovframework.third.homework.service.QitemVO;

@Service("qitemService")
public class QitemServiceImpl extends EgovAbstractServiceImpl implements QitemService {
	
	private static final Logger log = LoggerFactory.getLogger(QitemServiceImpl.class);
	
	@Resource(name = "qitemDAO")
	private QitemDAO qitemDAO;

	// 질문 등록
	@Override
	public void createQitem(QitemVO vo) throws Exception {
		qitemDAO.insertQitem(vo);
		log.info("INSERT 질문({})에 문항 등록 성공 idx: {}", vo.getQuestionIdx(), vo.getIdx());
	}

	// 질문에 소속된 문항 리스트 조회
	@Override
	public List<QitemVO> getQitemList(String questionIdx) throws Exception {
		List<QitemVO> list = qitemDAO.selectQitemListByQuestionIdx(questionIdx);
		log.info("SELECT 질문({})에 대한 문항 목록 조회 완료", questionIdx);
		return list;
	}

	// 문항 단일 조회
	@Override
	public QitemVO getQitem(String idx) throws Exception {
		QitemVO vo = qitemDAO.selectQitem(idx);
		log.info("SELECT 문항({}) 조회 완료", idx);
		return vo;
	}

	// 문항 수정
	@Override
	public void modifyQitem(QitemVO vo) throws Exception {
		qitemDAO.updateQitem(vo);
		log.info("UPDATE 문항({}) 수정 완료", vo.getIdx());
	}

	// 문항 삭제
	@Override
	public void removeQitem(String idx) throws Exception {
		qitemDAO.deleteQitem(idx);
		log.info("DELETE 문항({}) 삭제 완료", idx);
	}

}

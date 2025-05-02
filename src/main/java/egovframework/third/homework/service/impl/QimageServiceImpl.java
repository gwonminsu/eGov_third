package egovframework.third.homework.service.impl;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.third.homework.service.QimageService;
import egovframework.third.homework.service.QimageVO;

@Service("qimageService")
public class QimageServiceImpl extends EgovAbstractServiceImpl implements QimageService {
	
	private static final Logger log = LoggerFactory.getLogger(QimageServiceImpl.class);
	
	@Resource(name = "qimageDAO")
	private QimageDAO qimageDAO;

	// 질문 이미지 등록
	@Override
	public void createQimage(QimageVO vo) throws Exception {
		qimageDAO.insertQimage(vo);
		log.info("INSERT 질문({})에 질문 이미지 등록 성공 idx: {}", vo.getQuestionIdx(), vo.getIdx());
	}

	// 질문에 소속된 질문 이미지 조회
	@Override
	public QimageVO getQimageByQuestionIdx(String questionIdx) throws Exception {
		QimageVO vo = qimageDAO.selectQimageByQuestionIdx(questionIdx);
		log.info("SELECT 질문({})에 대한 질문 이미지 조회 완료", questionIdx);
		return vo;
	}

	// 질문 이미지 단일 조회
	@Override
	public QimageVO getQimage(String idx) throws Exception {
		QimageVO vo = qimageDAO.selectQimage(idx);
		log.info("SELECT 문항({}) 조회 완료", idx);
		return vo;
	}

	// 문항 삭제
	@Override
	public void removeQimage(String idx) throws Exception {
		qimageDAO.deleteQimage(idx);
		log.info("DELETE 문항({}) 삭제 완료", idx);
	}

	// 질문에 소속된 질문 이미지 삭제
	@Override
	public void removeQimageByQuestionIdx(String questionIdx) throws Exception {
		QimageVO vo = qimageDAO.selectQimageByQuestionIdx(questionIdx);
		qimageDAO.deleteQimageByQuestionIdx(questionIdx);
		log.info("DELETE 질문({})에 대한 질문 이미지({}) 삭제 완료", questionIdx, vo.getFileName());
	}

}

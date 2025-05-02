package egovframework.third.homework.service.impl;

import java.io.File;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.egovframe.rte.fdl.property.EgovPropertyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.third.homework.service.QimageService;
import egovframework.third.homework.service.QimageVO;

@Service("qimageService")
public class QimageServiceImpl extends EgovAbstractServiceImpl implements QimageService {
	
	private static final Logger log = LoggerFactory.getLogger(QimageServiceImpl.class);
	
    @Resource(name = "propertiesService")
    private EgovPropertyService propertiesService;
	
	@Resource(name = "qimageDAO")
	private QimageDAO qimageDAO;

	// 질문 이미지 등록
	@Override
	public void createQimage(String questionIdx, MultipartFile file) throws Exception {
		if (file == null) return;
        String baseDir = propertiesService.getString("file.upload.dir");
        File uploadDir = new File(baseDir);
        if (!uploadDir.exists()) uploadDir.mkdirs();
        
        String origName = file.getOriginalFilename();
        String ext = origName.substring(origName.lastIndexOf('.'));
        long size = file.getSize();
        
        // db에 질문 이미지 메타데이터 저장
        QimageVO vo = new QimageVO();
        vo.setQuestionIdx(questionIdx);
        vo.setFileName(origName);
        vo.setFilePath(baseDir);
        vo.setFileSize(size);
        vo.setExt(ext);
        qimageDAO.insertQimage(vo);
        log.info("INSERT 질문({})에 질문 이미지 등록 성공 idx: {}", vo.getQuestionIdx(), vo.getIdx());
        
        // 실제 파일 물리 저장
        File dest = new File(uploadDir, vo.getFileUuid() + ext);
        file.transferTo(dest);
        log.info("로컬 저장소에서 파일 저장 완료! : {}", vo.getFileUuid() + vo.getExt());		
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

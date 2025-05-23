package egovframework.third.cmmn;

import java.util.Collections;
import java.util.Map;

import org.springframework.http.HttpStatus;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(DataIntegrityViolationException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    @ResponseBody
    public Map<String,String> handleForeignKey(DataIntegrityViolationException ex) {
        return Collections.singletonMap("error", "외래키 제약 위반 오류가 발생했습니다");
    }
    
    // 근데 파일 제한 용량보다 클경우 실제 요청에서는 요청이 스프링 서버까지 전달되지 않아서 이 에러는 발생안됨 
    @ExceptionHandler(MaxUploadSizeExceededException.class)
    @ResponseStatus(HttpStatus.PAYLOAD_TOO_LARGE)
    @ResponseBody
    public Map<String, String> handleMaxUploadSize(MaxUploadSizeExceededException ex) {
        return Collections.singletonMap("error", "이미지 파일들의 크기가 너무 큽니다");
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    @ResponseBody
    public Map<String,String> handleOther(Exception ex) {
        return Collections.singletonMap("error", ex.getMessage());
    }
}
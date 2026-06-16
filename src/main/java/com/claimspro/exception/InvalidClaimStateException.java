package com.claimspro.exception;

public class InvalidClaimStateException extends RuntimeException {
    public InvalidClaimStateException(String message) {
        super(message);
    }
}

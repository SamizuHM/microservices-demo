package com.devproblems.grpc.server;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.TypeReference;
import com.devproblems.grpc.proto.*;
import io.grpc.stub.StreamObserver;
import net.devh.boot.grpc.server.service.GrpcService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

@GrpcService
public class CurrencyServiceServer extends CurrencyServiceGrpc.CurrencyServiceImplBase {
    private static final Logger logger = LoggerFactory.getLogger(CurrencyServiceServer.class);

    private Map<String, Double> currencyData;

    @Value("${currency.data.file}")
    private String currencyDataFile;

    @Autowired
    private ResourceLoader resourceLoader;

    @PostConstruct
    public void init() throws IOException {
        // Load resource using ResourceLoader
        Resource resource = resourceLoader.getResource("classpath:" + currencyDataFile);

        // Read JSON data
        try (InputStream inputStream = resource.getInputStream()) {
            byte[] bytes = inputStream.readAllBytes();
            String jsonContent = new String(bytes);

            // Parse JSON using fastjson
            currencyData = JSON.parseObject(jsonContent, new TypeReference<Map<String, Double>>(){});
            logger.info("Loaded currency data: {}", currencyData);
        } catch (IOException e) {
            logger.error("Failed to load currency data: {}", e.getMessage());
            throw e;
        }
    }

    @Override
    public void getSupportedCurrencies(Empty request, StreamObserver<GetSupportedCurrenciesResponse> responseObserver) {
        logger.info("Getting supported currencies...");
        GetSupportedCurrenciesResponse response = GetSupportedCurrenciesResponse.newBuilder()
                .addAllCurrencyCodes(currencyData.keySet())
                .build();
        responseObserver.onNext(response);
        responseObserver.onCompleted();
    }

    @Override
    public void convert(CurrencyConversionRequest request, StreamObserver<Money> responseObserver) {
        try {
            Money from = request.getFrom();
            double fromValue = from.getUnits() + from.getNanos() / 1e9;
            double euros = fromValue / currencyData.get(from.getCurrencyCode());
            double toValue = euros * currencyData.get(request.getToCode());

            Money result = Money.newBuilder()
                    .setCurrencyCode(request.getToCode())
                    .setUnits((long) toValue)
                    .setNanos((int) ((toValue % 1) * 1e9))
                    .build();

            logger.info("Conversion request successful");
            responseObserver.onNext(result);
            responseObserver.onCompleted();
        } catch (Exception e) {
            logger.error("Conversion request failed: {}", e.getMessage());
            responseObserver.onError(e);
        }
    }
}

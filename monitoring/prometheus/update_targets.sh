#!/bin/bash

# Cloud Map 서비스 리스트 (9개)
SERVICES=(
  "program-service"
  "venue-service"
  "payment-service"
  "queue-service"
  "booking-service"
  "gateway-server"
  "eureka-server"
  "user-service"
  "config-server"
)

REGION="ap-northeast-2"
NAMESPACE="first-ticket"
# 실제 파일이 저장될 절대 경로
OUTPUT_FILE="/home/ubuntu/firstticket/infra/monitoring/prometheus/targets.json"
TEMP_FILE="/home/ubuntu/firstticket/infra/monitoring/prometheus/targets.json.tmp"

# JSON 시작
echo "[" > $TEMP_FILE

FIRST=true
for SERVICE in "${SERVICES[@]}"; do
  # AWS CLI로 IP 조회 (Attributes 내의 IP 추출)
  IP=$(aws servicediscovery discover-instances \
    --namespace-name $NAMESPACE \
    --service-name $SERVICE \
    --region $REGION \
    --query 'Instances[0].Attributes.AWS_INSTANCE_IPV4' --output text)

  # IP가 정상적으로 조회된 경우만 JSON에 추가
  if [ "$IP" != "None" ] && [ -n "$IP" ]; then
    # 첫 번째 원소가 아니면 이전 줄 끝에 콤마 추가
    if [ "$FIRST" = false ]; then
      echo "  ," >> $TEMP_FILE
    fi

    # eureka-server는 8761 포트 사용
    if [ "$SERVICE" = "eureka-server" ]; then
      PORT=8761
    else
      PORT=8080
    fi

    echo "  {" >> $TEMP_FILE
    echo "    \"targets\": [\"$IP:$PORT\"]," >> $TEMP_FILE
    echo "    \"labels\": { \"job\": \"$SERVICE\" }" >> $TEMP_FILE
    echo "  }" >> $TEMP_FILE
    FIRST=false
  fi
done

# JSON 끝
echo "]" >> $TEMP_FILE

# 임시 파일을 실제 파일로 교체 (파일 쓰기 중 읽기 에러 방지)
mv $TEMP_FILE $OUTPUT_FILE

echo "Targets updated at $(date)"


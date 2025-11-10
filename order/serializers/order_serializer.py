from rest_framework import serializers
from product.serializers import ProductSerializer
from ..models import Order

class OrderSerializer(serializers.ModelSerializer):
    product = ProductSerializer(many=True)
    total = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = ['user', 'product', 'total']
        read_only_fields = ['total']

    def get_total(self, instance):
        return sum(product.price for product in instance.product.all())

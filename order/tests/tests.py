from django.test import TestCase
from django.contrib.auth.models import User
from product.models import Product
from order.models import Order
from order.serializers import OrderSerializer

class OrderSerializerTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(username='rafa')

        self.product1 = Product.objects.create(title='Produto A', price=10)
        self.product2 = Product.objects.create(title='Produto B', price=15)

        self.order = Order.objects.create(user=self.user)
        self.order.product.set([self.product1, self.product2])

    def test_total_field(self):
        serializer = OrderSerializer(self.order)
        data = serializer.data
        self.assertEqual(data['total'], 25)

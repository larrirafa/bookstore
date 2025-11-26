from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import AllowAny

from product.models import Product
from product.serializers.product_serializer import ProductSerializer


class ProductViewSet(ModelViewSet):
    authentication_classes = []        # Sem autenticação
    permission_classes = [AllowAny]    # Permite acesso público
    serializer_class = ProductSerializer

    def get_queryset(self):
        return Product.objects.all().order_by('id')

from django.test import TestCase
from product.models import Category, Product


class CategoryModelTest(TestCase):
    def setUp(self):
        self.category = Category.objects.create(
            title="Eletrônicos",
            slug="eletronicos",
            description="Produtos eletrônicos em geral"
        )

    def test_category_creation(self):
        self.assertEqual(self.category.title, "Eletrônicos")
        self.assertTrue(self.category.active)
        self.assertEqual(str(self.category), self.category.title)


class ProductModelTest(TestCase):
    def setUp(self):
        self.category = Category.objects.create(
            title="Livros",
            slug="livros",
            description="Categoria de livros"
        )
        self.product = Product.objects.create(
            title="Livro Django",
            description="Aprenda Django com exemplos práticos",
            price=100,
            active=True
        )
        self.product.category.add(self.category)

    def test_product_creation(self):
        self.assertEqual(self.product.title, "Livro Django")
        self.assertEqual(self.product.price, 100)
        self.assertIn(self.category, self.product.category.all())

    def test_product_is_active_by_default(self):
        product = Product.objects.create(title="Produto Teste", price=50)
        self.assertTrue(product.active)

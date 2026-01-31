import json
from rest_framework import status
from rest_framework.test import APIClient, APITestCase
from django.urls import reverse

from product.factories import CategoryFactory
from product.models import Category


class CategoryViewSet(APITestCase):
    client = APIClient()

    def setUp(self):
        self.category = CategoryFactory(title="books")

    def test_get_all_category(self):
        response = self.client.get(reverse("category-list", kwargs={"version": "v1"}))

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        category_data = response.json()
        results = category_data.get("results", category_data)

        self.assertGreater(len(results), 0)
        self.assertEqual(results[0]["title"], self.category.title)

    def test_create_category(self):
        data = json.dumps(
            {
                "title": "technology",
            }
        )

        response = self.client.post(
            reverse("category-list", kwargs={"version": "v1"}),
            data=data,
            content_type="application/json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        created_category = Category.objects.get(title="technology")

        self.assertEqual(created_category.title, "technology")

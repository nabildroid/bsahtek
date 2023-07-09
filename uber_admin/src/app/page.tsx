"use client";

import { M } from 'drizzle-orm/query-promise.d-2e42fbc9';
import * as FoodRepository from '../local_repository/food';
import React, { useState, ChangeEvent, FormEvent } from 'react';
import { TypeOf, z } from 'zod';
import { NewFood } from '@/utils/types';


const NewFoodForm: React.FC = () => {
  const [food, setFood] = useState<z.infer<typeof NewFood>>({
    photo: '',
    name: '',
    category: "hello",
    county: "algeria",
    description: "food for all good",
    isPromoted: false,
    sellerAddress: "cheraga",
    sellerName: "Superat Zigadi",
    sellerID: "HNcUoKLtz6tOs5U7X98E",
    sellerPhoto: "https://arib.shop/logo1.png",
    tags: ["food", "good"],
    wilaya: "alger",
    latitude: 5,
    longitude: 12,
    price: 12.23,
    originalPrice: 52.1,
  });

  const handleInputChange = (event: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = event.target

    if (typeof ((food as any)[name]) === "number") {
      setFood((prevFood) => ({ ...prevFood, [name]: Number(value) }));
      return;
    }
    setFood((prevFood) => ({ ...prevFood, [name]: value }));
  };

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    // Do something with the food data, e.g., send it to an API

    await FoodRepository.add(food);

    console.log(food);
    // Reset the form

  };

  return (
    <div className="max-w-md mx-auto">
      <h1 className="text-2xl font-bold mb-4">Add New Food</h1>
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label className="block mb-1">Photo:</label>
          <input
            type="text"
            name="photo"
            value={food.photo}
            onChange={handleInputChange}
            required
            className="w-full border border-gray-300 px-3 py-2 rounded-lg"
          />
        </div>
        <div className="mb-4">
          <label className="block mb-1">Name:</label>
          <input
            type="text"
            name="name"
            value={food.name}
            onChange={handleInputChange}
            required
            className="w-full border border-gray-300 px-3 py-2 rounded-lg"
          />
        </div>
        <div className="mb-4">
          <label className="block mb-1">Company Name:</label>
          <input
            type="text"
            name="Seller Name"
            value={food.sellerName}
            onChange={handleInputChange}
            required
            className="w-full border border-gray-300 px-3 py-2 rounded-lg"
          />
        </div>

        <div className="mb-4">
          <label className="block mb-1">Company ID:</label>
          <input
            type="text"
            name="seller ID"
            value={food.sellerID}
            onChange={handleInputChange}
            required
            className="w-full border border-gray-300 px-3 py-2 rounded-lg"
          />
        </div>






        <div className="mb-4">
          <label className="block mb-1">Price:</label>
          <input
            type="text"
            name="price"
            value={food.price}
            onChange={handleInputChange}
            required
            className="w-full border border-gray-300 px-3 py-2 rounded-lg"
          />
        </div>
        <div className="mb-4">
          <label className="block mb-1">Latitude (y):</label>
          <input
            type="text"
            name="latitude"
            value={food.latitude}
            onChange={handleInputChange}
            required
            className="w-full border border-gray-300 px-3 py-2 rounded-lg"
          />
        </div>
        <div className="mb-4">
          <label className="block mb-1">Longitude (x smallest):</label>
          <input
            type="text"
            name="longitude"
            value={food.longitude}
            onChange={handleInputChange}
            required
            className="w-full border border-gray-300 px-3 py-2 rounded-lg"
          />
        </div>
        <button
          type="submit"
          className="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded"
        >
          Submit
        </button>
      </form>
    </div>
  );
};

export default NewFoodForm;
